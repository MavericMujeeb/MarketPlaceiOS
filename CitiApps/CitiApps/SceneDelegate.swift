//
//  SceneDelegate.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

import UIKit
import FluentUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
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
            
            var meetingFinalLink = "";
            if let meetingLink = queryItems.first(where: { $0.name == "meetingURL" })?.value{
                
                var joinWeburl = getQueryStringParameter(url: meetingLink, param: "JoinWebUrl")
                let splitJoinUrl = joinWeburl?.split(separator: "&")
            
                print("JOINWEBURL")
                print(joinWeburl)
                print("splitJoinUrl")
                print(splitJoinUrl?[0])

                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                
                let introVC = IntroViewController();
                introVC.authHandler = appDelegate.authHandler
                introVC.createCallingContextFunction = { () -> CallingContext in
                    return CallingContext(tokenFetcher: appDelegate.tokenService.getCommunicationToken)
                }
                
                introVC.teamsMeetingLink = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_OTkwMDI2YjItYWVhNC00MDdjLTkwZTMtZjIzNGE0YmQ3MzRm%40thread.v2/0?context=%7b%22Tid%22%3a%224c4985fe-ce8e-4c2f-97e6-b037850b777d%22%2c%22Oid%22%3a%22a8dc642c-0094-4b86-9181-ede5a8abc243%22%7d"
                
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
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Main") as! ViewController
                vc.handleExternalLinks = true
                vc.meetingLink = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_OTkwMDI2YjItYWVhNC00MDdjLTkwZTMtZjIzNGE0YmQ3MzRm%40thread.v2/0?context=%7b%22Tid%22%3a%224c4985fe-ce8e-4c2f-97e6-b037850b777d%22%2c%22Oid%22%3a%22a8dc642c-0094-4b86-9181-ede5a8abc243%22%7d"
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

