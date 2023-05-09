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
import FlutterPluginRegistrant
import PushKit
import AzureCommunicationCalling
import WindowsAzureMessaging
import UserNotifications

#if canImport(Combine)
import Combine
#endif

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
                        MSNotificationHub.start(connectionString: "Endpoint=sb://ACSCitiPushService.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=u3NgR63Wc9Z1Jklf2YF80MY6v/qkaxslfRctMoZgNGU=", hubName: "ACSCitiPush")
                    }
                }
            }
        }
        
        initializeDependencies()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub, didReceivePushNotification message: MSNotificationHubMessage) {
        print(message.body)
        print(message.title)
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
        
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
        
        controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        UINavigationBar.appearance().tintColor = .white
        UITabBar.appearance().tintColor = .white
    }
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        appPubs.pushToken = registry.pushToken(for: .voIP) ?? nil
    }

    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith")
        let callNotification = PushNotificationInfo.fromDictionary(payload.dictionaryPayload)
        let userDefaults: UserDefaults = .standard
        let isCallKitInSDKEnabled = userDefaults.value(forKey: "isCallKitInSDKEnabled") as? Bool ?? false
        if isCallKitInSDKEnabled {
            #if BETA
            let callKitOptions = CallKitOptions(with: CallKitObjectManager.createCXProvideConfiguration())
            CallClient.reportIncomingCallFromKillState(with: callNotification, callKitOptions: callKitOptions) { error in
                if error == nil {
                    self.appPubs.pushPayload = payload
                }
            }
            #endif
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
    
//    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
//        print("didReceiveRemoteNotification")
//    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken")
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


