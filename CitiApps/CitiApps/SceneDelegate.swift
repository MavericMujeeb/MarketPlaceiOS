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
        
        
        if let userActivity = connectionOptions.userActivities.first {
            if let incomingURL = userActivity.webpageURL {
                let webPageUrl = incomingURL.absoluteString
                guard let urlComponents = URLComponents(string: webPageUrl) else { return }

                // Create array of existing query items
                let queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

                var meetingFinalLink: String? = "";
                if let meetingLink = queryItems.first(where: { $0.name == "meetingURL" })?.value{

                    let joinWeburl = getQueryStringParameter(url: meetingLink, param: "JoinWebUrl")
                    let splitJoinUrl = joinWeburl?.components(separatedBy: "&")
                    meetingFinalLink = splitJoinUrl?[0]

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Main") as! ViewController
                    vc.handleExternalLinks = true
                    vc.meetingLink = meetingFinalLink

                    DispatchQueue.main.async {
                        let nav = UINavigationController.init(rootViewController: vc)
                        nav.navigationBar.backgroundColor = .black
                        self.window?.rootViewController = nav
                        self.window?.makeKeyAndVisible()
                    }

                }
            }
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    private func joinTeamsMeeting(result: FlutterResult, args: NSDictionary) {
        let mettingLink = args.value(forKey: "meeting_id") as! String        
        let teamsCallingViewController = TeamsCallingViewController()
        teamsCallingViewController.teamsLink = mettingLink
        teamsCallingViewController.startCall()
    }


    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let webPageUrl = userActivity.webpageURL?.absoluteString else { return }
        guard let urlComponents = URLComponents(string: webPageUrl) else { return }

        // Create array of existing query items
        let queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        var meetingFinalLink: String? = "";
        if let meetingLink = queryItems.first(where: { $0.name == "meetingURL" })?.value{

            let joinWeburl = getQueryStringParameter(url: meetingLink, param: "JoinWebUrl")
            let splitJoinUrl = joinWeburl?.components(separatedBy: "&")
            meetingFinalLink = splitJoinUrl?[0]

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Main") as! ViewController
            vc.handleExternalLinks = true
            vc.meetingLink = meetingFinalLink

            self.window?.rootViewController = UINavigationController.init(rootViewController: vc)
            self.window?.makeKeyAndVisible()
        }
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }

}

