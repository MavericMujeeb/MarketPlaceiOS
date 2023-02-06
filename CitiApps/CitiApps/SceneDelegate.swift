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
        
        /*
         * Flutter Engine to listen to join call method call from Flutter engine and trigger the native view to perform call/chat actions
         */
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
//        let rootVC = self.window?.rootViewController
        let teamsCallingViewController = TeamsCallingViewController()
        teamsCallingViewController.teamsLink = mettingLink
        teamsCallingViewController.startCall()
        
//        rootVC?.present(teamsCallingViewController, animated: true)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        /*
         * Handled deeplink url
         * Parse the meeting url and obtain the actual teams url and pass to teamview controller to perform next actions
         */
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

                let teamsCallingViewController = TeamsCallingViewController()
                teamsCallingViewController.teamsLink = meetingFinalLink
                teamsCallingViewController.startCall()
                
//                self.window?.rootViewController?.present( UINavigationController.init(rootViewController: teamsCallingViewController), animated: true)
                
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

