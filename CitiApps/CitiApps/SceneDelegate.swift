//
//  SceneDelegate.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

import UIKit
import FluentUI
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        

        let acsChannel = FlutterMethodChannel(
            name: "com.citi.marketplace.host",
            binaryMessenger: appDelegate.controller.binaryMessenger
        )
        
        acsChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard call.method == "joinCallClick" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.joinTeamsMeeting(result: result, args: call.arguments as! NSDictionary)
        })
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    private func joinTeamsMeeting(result: FlutterResult, args: NSDictionary) {
        let mettingLink = args.value(forKey: "meeting_id") as! String        
        let rootVC = self.window?.rootViewController
        let teamsCallingViewController = TeamsCallingViewController()
        teamsCallingViewController.teamsLink = mettingLink
        
        rootVC?.present(teamsCallingViewController, animated: true)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        guard let webPageUrl = userActivity.webpageURL?.absoluteString else { return }
        
        if let urlComponent = URLComponents(string: webPageUrl) {
            // queryItems is an array of "key name" and "value"
            guard var urlComponents = URLComponents(string: webPageUrl) else { return }

            // Create array of existing query items
            let queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
            
            var meetingFinalLink: String? = "";
            if let meetingLink = queryItems.first(where: { $0.name == "meetingURL" })?.value{
                
                let joinWeburl = getQueryStringParameter(url: meetingLink, param: "JoinWebUrl")
                let splitJoinUrl = joinWeburl?.components(separatedBy: "&")
                meetingFinalLink = splitJoinUrl?[0]
                
//                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                
//                let introVC = IntroViewController();
//                introVC.authHandler = appDelegate.authHandler
//                introVC.createCallingContextFunction = { () -> CallingContext in
//                    return CallingContext(tokenFetcher: appDelegate.tokenService.getCommunicationToken)
//                }
//
//                introVC.teamsMeetingLink = meetingFinalLink
//
//                let fluentNavVc = PortraitOnlyNavController(rootViewController: introVC)
//                fluentNavVc.view.backgroundColor = FluentUI.Colors.surfaceSecondary
//                fluentNavVc.view.tintColor = FluentUI.Colors.iconPrimary
//                fluentNavVc.navigationBar.topItem?.backButtonDisplayMode = .minimal
//
//                let appearance = UINavigationBarAppearance()
//                appearance.backgroundColor = FluentUI.Colors.surfaceSecondary
//                appearance.titleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
//                appearance.largeTitleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
//
//                fluentNavVc.navigationBar.standardAppearance = appearance
//                fluentNavVc.navigationBar.scrollEdgeAppearance = appearance
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Main") as! ViewController
                vc.handleExternalLinks = true
                vc.meetingLink = meetingFinalLink
                self.window?.rootViewController = UINavigationController.init(rootViewController: vc)
            }

        }
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

