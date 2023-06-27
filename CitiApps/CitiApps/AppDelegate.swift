//
//  AppDelegate.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 16/01/23.
//

import UIKit
import MSAL
import Flutter
import FluentUI
import PushKit
import AzureCommunicationCalling
import WindowsAzureMessaging
import UserNotifications
import SwiftUI
import AzureCommunicationUICalling
import Foundation

#if canImport(Combine)
import Combine
#endif

//Use this to initialize call agent on User Login or on app re-open.
//Register call agent

var globalCallAgent : CallAgent?
var globalIncomingCall: IncomingCall?
var globalDeviceManager: DeviceManager?


@main
class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, MSNotificationHubDelegate {

    private (set) var appSettings: AppSettings!
    private (set) var authHandler: AADAuthHandler!
    private (set) var tokenService: TokenService!
    
    lazy var flutterEngine = FlutterEngine()
    var controller : FlutterViewController!
    
    let appPubs = AppPubs()
    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue:DispatchQueue.main)

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in

                if (granted)
                {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                        UNUserNotificationCenter.current().delegate = self
                        MSNotificationHub.setDelegate(self)
                        MSNotificationHub.start(connectionString: "Endpoint=sb://ACSCitiPushServiceNew.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=hPhXI6h3xPKb0MhtNq60mM9hsXVtC1Ia8ty6R4V4Dc8=", hubName: "ACSCitiPushServiceNew")
                    }
                }
            }
        }
        
        initializeDependencies()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub, didReceivePushNotification message: MSNotificationHubMessage) {
        print("didReceivePushNotification")

        let rootVC = UIApplication.shared.keyWindow?.rootViewController

        // create the alert
        let alert = UIAlertController(title: "New Message", message: message.body , preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {action in
            rootVC?.dismiss(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.destructive, handler: {action in
            
            rootVC?.dismiss(animated: true)
            //open chat screen
            let storageUserDefaults = UserDefaults.standard
            var bankerEmailId = storageUserDefaults.value(forKey: StorageKeys.bankerEmailId) as! String

            let chatController = ChatController(chatAdapter: nil, rootViewController: self.window?.rootViewController)
            chatController.bankerEmailId = bankerEmailId
            chatController.isForCall = false
            chatController.prepareChatComposite()
            
        }))

        // show the alert
        rootVC?.present(alert, animated: true)
    }
    
    func openChatScreen () {
        
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("com.citi.acsdemo") == .orderedSame,
            let view = url.host {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
        }
        // Required for AAD Authentication
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }

    // MARK: Private Functions
    private func initializeDependencies() {
        appSettings = AppSettings()
        authHandler = AADAuthHandler(appSettings: appSettings)
        
        flutterEngine.run(withEntrypoint: nil, initialRoute: "/screen_contact_center")
        controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        UINavigationBar.appearance().tintColor = .white
        UITabBar.appearance().tintColor = .white
    }
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        appPubs.pushToken = registry.pushToken(for: .voIP) ?? nil
    }
    
   
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let callNotification = PushNotificationInfo.fromDictionary(payload.dictionaryPayload)
        let userDefaults: UserDefaults = .standard
        let isCallKitInSDKEnabled = userDefaults.value(forKey: "isCallKitInSDKEnabled") as? Bool ?? false
        if isCallKitInSDKEnabled {
            let callKitOptions = CallKitOptions(with: CallKitObjectManager.createCXProvideConfiguration())
            CallClient.reportIncomingCallFromKillState(with: callNotification, callKitOptions: callKitOptions) { error in
                print(error)
                if error == nil {
                    self.appPubs.pushPayload = payload
                    let incomingHostingController = UIHostingController(rootView: incomingCallView)
                    let rootVC = UIApplication.shared.keyWindow?.rootViewController
                    rootVC?.present(incomingHostingController, animated: true, completion: nil)
                }
            }
        } else {
            let incomingCallReporter = CallKitIncomingCallReporter()
            incomingCallReporter.reportIncomingCall(callId: callNotification.callId.uuidString,
                                                   caller: callNotification.from,
                                                   callerDisplayName: callNotification.fromDisplayName,
                                                    videoEnabled: callNotification.incomingWithVideo) { error in
                if error == nil {
                    self.appPubs.pushPayload = payload
                }
            }
        }
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Create a push registry object
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
}

class AppPubs {
    init() {
        self.pushPayload = nil
        self.pushToken = nil
    }

    @Published var pushPayload: PKPushPayload?
    @Published var pushToken: Data?
}


