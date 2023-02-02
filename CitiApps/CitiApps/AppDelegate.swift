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
    var controller : FlutterViewController!

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeDependencies()
        flutterEngine.run(withEntrypoint: nil, initialRoute: "/screen_contact_center")
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
        controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        UINavigationBar.appearance().tintColor = .white
        UITabBar.appearance().tintColor = .white
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
//        //communicationTokenFetchUrl - keep the communicationTokenFetchUrl
//        tokenService = TokenService(tokenACS:"eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjYxZmY4Yjg5LTY2ZjktNGMxYS04N2FkLTJlODI2MDc1MzdkNF8wMDAwMDAxNi1hMzhlLTc1ZGEtNWFhZC05MjNhMGQwMGUwNzkiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzUwOTg5MDMiLCJleHAiOjE2NzUxODUzMDMsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQsdm9pcCIsInJlc291cmNlSWQiOiI2MWZmOGI4OS02NmY5LTRjMWEtODdhZC0yZTgyNjA3NTM3ZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc1MDk4OTAzfQ.jM2Q_dmzJOByg09Z3UD4SkAcifJoY95KzCoWsN3RuOc4nhcY3mnclg_IXOLC4mgp0pMJl7-MZzIE7OSxn1MVo6eD9Tm5qsbktWduOp_R14GcHAA99UJ3GsdoGOC1BU-HfrCPe3GOXy1s-sQHl-A1zQXrjBIoTY4hJlGQ2kfNNEMG80kJH2y6hlsa6NLM2JV4z1l34XpP_qSGmDkumQNh8ZUmONpFNU4mzyagMj-E8Nwn6HP0MCntZIHW-JUs-Cspxyzmwc5RPh2Qr0YdM3_ZUy2R5zgum-OE-N5hwTE8-8muiiVII7QkDMnH7ddQVLYPxiPT417fok6MDD920PBLbw", communicationTokenFetchUrl: "http://10.189.86.98:7071/api/HttpTrigger1", getAuthTokenFunction: { () -> String? in
////        tokenService = TokenService(communicationTokenFetchUrl: "http://localhost:7071/api/TeamsIntegration", getAuthTokenFunction: { () -> String? in
//            return self.authHandler.authToken
//        })
    }
    
    func initializeFlutterEngine() {}
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if(userActivity.activityType == NSUserActivityTypeBrowsingWeb){
            let url = userActivity.webpageURL
            let urlString = url?.absoluteString
        }
        
        return true
    }
    
    private func setupNavigationController() -> UIViewController {
        let fluentNavVc = PortraitOnlyNavController(rootViewController: IntroViewController())
        fluentNavVc.view.backgroundColor = FluentUI.Colors.surfaceSecondary
        fluentNavVc.view.tintColor = FluentUI.Colors.iconPrimary
        fluentNavVc.navigationBar.topItem?.backButtonDisplayMode = .minimal
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = FluentUI.Colors.surfaceSecondary
        appearance.titleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]

        fluentNavVc.navigationBar.standardAppearance = appearance
        fluentNavVc.navigationBar.scrollEdgeAppearance = appearance
        return fluentNavVc
    }
    
    private func joinTeamsMeeting(result: FlutterResult, args: NSDictionary) {
        print("start")
        let mettingLink = args.value(forKey: "meeting_id")
        print("end-1")
//        let introVC = JoinCallViewController();
//        print("end-2")
//        introVC.authHandler = self.authHandler
//        print("end-3")
//        introVC.createCallingContextFunction = { () -> CallingContext in
//            return CallingContext(tokenFetcher: self.tokenService.getCommunicationToken)
//        }
//        print("end-3")
//        introVC.teamsMeetingLink = mettingLink as? String
//        print("end-4")
        
//        let fluentNavVc = PortraitOnlyNavController(rootViewController: introVC)
//        fluentNavVc.view.backgroundColor = FluentUI.Colors.surfaceSecondary
//        fluentNavVc.view.tintColor = FluentUI.Colors.iconPrimary
//        fluentNavVc.navigationBar.topItem?.backButtonDisplayMode = .minimal
//
//        let appearance = UINavigationBarAppearance()
//        appearance.backgroundColor = FluentUI.Colors.surfaceSecondary
//        appearance.titleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
//        appearance.largeTitleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
//
//        fluentNavVc.navigationBar.standardAppearance = appearance
//        fluentNavVc.navigationBar.scrollEdgeAppearance = appearance
//
        
//        let nav = UIApplication
//            .shared
//            .connectedScenes
//            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
//            .first?.rootViewController as? UINavigationController
        
    }
    
    private func startChat(result: FlutterResult, args: NSDictionary) {
        
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

