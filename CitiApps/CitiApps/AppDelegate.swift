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
var acceptedCall : Call?
var globalDeviceManager: DeviceManager?


@main
class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, MSNotificationHubDelegate {

    private (set) var appSettings: AppSettings!
    private (set) var authHandler: AADAuthHandler!
    private (set) var tokenService: TokenService!
    
    var flutterEngine = FlutterEngine()
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
                        MSNotificationHub.start(connectionString: ACSResources.acs_notificationHub_endpoint, hubName: ACSResources.acs_notificationHub_namespace)
                    }
                }
            }
        }
        
        initFlutterEngine()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
  
    
    func notificationHub(_ notificationHub: MSNotificationHub, didReceivePushNotification message: MSNotificationHubMessage) {
        CitiConstants.isFromNotification = true
        
        var rootVC = UIApplication.shared.keyWindow?.rootViewController
        
        
        if(rootVC is UINavigationController){
            rootVC = (rootVC as! UINavigationController).visibleViewController!
        }
        if(rootVC is DashboardViewController) {
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
                var bankerEmailId = storageUserDefaults.string(forKey: StorageKeys.bankerEmailId) ?? ACSResources.bankerUserEmail
                var customerUserName = storageUserDefaults.string(forKey: StorageKeys.loginUserName) ?? ACSResources.customerUserName
                
                let chatController = ChatController(chatAdapter: nil, rootViewController: rootVC)
                chatController.bankerEmailId = bankerEmailId
                chatController.custUserName = customerUserName
                chatController.isForCall = false
                chatController.prepareChatComposite()
                
            }))
            // show the alert
            rootVC?.present(alert, animated: true)
        }
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
    private func initFlutterEngine() {
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
    
    func registerIncomingCallClient() {
        let incomingCallController = ACSIncomingCallConntroller()
        incomingCallController.resigterIncomingCallClient(appPubs: appPubs)
    }
    

    func provideCallKitRemoteInfo(callerInfo: CallerInfo) -> CallKitRemoteInfo
    {
        let callKitRemoteInfo = CallKitRemoteInfo()
        callKitRemoteInfo.displayName = ACSResources.bankerUserName
        callKitRemoteInfo.handle = CXHandle(type: .generic, value: "VALUE_TO_CXHANDLE")
        return callKitRemoteInfo
    }
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith ------ ")
        let callNotification = PushNotificationInfo.fromDictionary(payload.dictionaryPayload)
        let userDefaults: UserDefaults = .standard
        let isCallKitInSDKEnabled = userDefaults.value(forKey: "isCallKitInSDKEnabled") as? Bool ?? false
        
        
        if isCallKitInSDKEnabled {
            print("Coming here ---- isCallKitInSDKEnabled")
            let callKitOptions = CallKitOptions(with: CallKitObjectManager.createCXProvideConfiguration())
            callKitOptions.provideRemoteInfo = self.provideCallKitRemoteInfo

            CallClient.reportIncomingCallFromKillState(with: callNotification, callKitOptions: callKitOptions) { error in
                if error == nil {
                    self.appPubs.pushPayload = payload
                }
            }
        } else {
            print("Coming here ---- 232323")
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
        voipRegistry.delegate = self
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


