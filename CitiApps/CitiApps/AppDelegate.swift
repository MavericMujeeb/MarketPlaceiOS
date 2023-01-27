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

@main
class AppDelegate: FlutterAppDelegate {

    private (set) var appSettings: AppSettings!
    private (set) var authHandler: AADAuthHandler!
    private (set) var tokenService: TokenService!
    
    lazy var flutterEngine = FlutterEngine()

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initializeDependencies()

        flutterEngine.run(withEntrypoint: nil, initialRoute: "/screen_contact_center")
        
        
        GeneratedPluginRegistrant.register(with: self.flutterEngine);

        
        let controller : FlutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        let acsChannel = FlutterMethodChannel(
            name: "com.citi.marketplace.host",
            binaryMessenger: controller.binaryMessenger
        )
        
        acsChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          guard call.method == "joinCallClick" else {
            result(FlutterMethodNotImplemented)
            return
          }
            self?.joinTeamsMeeting(result: result, args: call.arguments as! NSDictionary)
            
        })
        
        UINavigationBar.appearance().tintColor = .white
        UITabBar.appearance().tintColor = .white
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

//    // MARK: UISceneSession Lifecycle
//    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }

//    override func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("com.citi.acsdemo") == .orderedSame,
            let view = url.host {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print(parameters)
        }
        // Required for AAD Authentication
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }

    // MARK: Private Functions
    private func initializeDependencies() {
        appSettings = AppSettings()
        authHandler = AADAuthHandler(appSettings: appSettings)
        //communicationTokenFetchUrl - keep the communicationTokenFetchUrl
        tokenService = TokenService(tokenACS:"eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjdlOTRjMzVlLThjZGItNDhiOC04NDcyLTk2Njk4OWQ4NGZkMF8wMDAwMDAxNi04ZmM5LTcwZjItZDEwNy01NzQ4MjIwMGNhNzkiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzQ3NjcyMjQiLCJleHAiOjE2NzQ4NTM2MjQsInJnbiI6ImluIiwiYWNzU2NvcGUiOiJ2b2lwIiwicmVzb3VyY2VJZCI6IjdlOTRjMzVlLThjZGItNDhiOC04NDcyLTk2Njk4OWQ4NGZkMCIsInJlc291cmNlTG9jYXRpb24iOiJpbmRpYSIsImlhdCI6MTY3NDc2NzIyNH0.EKFA2GsfrDlpXg4ABux_GFCToMX44BuRyFFLybAT-yze2rlG526CWOKE2Tagdhoa4x0FeFRr3On5XFv0Z_h0BFU8S0cJ9W-_d4kPiHchCy8EyudXnqd-tlPmf4j4pTJJppf5Y587SgqwMRQhYqPZkClXaG71FJKBKvSe9yWWdAVXuR75DWjSjP12-cCDzxN-uZ8yMLkM37PPb_vPVJOt8RFvzk6m5ganwlraTHav1TShR0htmxaK-nF4mnMrZA15U7RIiOhrv74L2mWfhIruGX8lyCyNkFQc08V8JX-xN1StVfAiJ47KGmSuucZOmNS3BBULWNEEMUMuE56KhsOgmQ", communicationTokenFetchUrl: "http://10.189.86.98:7071/api/HttpTrigger1", getAuthTokenFunction: { () -> String? in
//        tokenService = TokenService(communicationTokenFetchUrl: "http://localhost:7071/api/TeamsIntegration", getAuthTokenFunction: { () -> String? in
            return self.authHandler.authToken
        })
    }
    
    func initializeFlutterEngine() {}
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if(userActivity.activityType == NSUserActivityTypeBrowsingWeb){
            let url = userActivity.webpageURL
            let urlString = url?.absoluteString
        }
        
        return true
    }
    
    private func joinTeamsMeeting(result: FlutterResult, args: NSDictionary) {
        let mettingLink = args.value(forKey: "meeting_id")
        
        print("mettingLink")
        print(mettingLink)
        let introVC = IntroViewController();
        introVC.authHandler = self.authHandler
        introVC.createCallingContextFunction = { () -> CallingContext in
            return CallingContext(tokenFetcher: self.tokenService.getCommunicationToken)
        }
        introVC.teamsMeetingLink = mettingLink as? String
        
        let fluentNavVc = PortraitOnlyNavController(rootViewController: introVC)
        fluentNavVc.view.backgroundColor = FluentUI.Colors.surfaceSecondary
        fluentNavVc.view.tintColor = FluentUI.Colors.iconPrimary
        fluentNavVc.navigationBar.topItem?.backButtonDisplayMode = .minimal
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = FluentUI.Colors.surfaceSecondary
        appearance.titleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]

        fluentNavVc.navigationBar.standardAppearance = appearance
        fluentNavVc.navigationBar.scrollEdgeAppearance = appearance
        
        let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        nav?.present(fluentNavVc, animated: true)

    }
}

class PortraitOnlyNavController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var shouldAutorotate: Bool { false }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}

