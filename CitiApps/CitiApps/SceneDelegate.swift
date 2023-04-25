//
//  SceneDelegate.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

import UIKit
import FluentUI
import Flutter
import PIPKit
import AzureCommunicationUIChat

#if canImport(Combine)
import Combine
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let storageUserDefaults = UserDefaults.standard

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        self.window?.overrideUserInterfaceStyle = .light
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: myNotificationName, object: nil)
        
        let acsChannel = FlutterMethodChannel(
            name: CitiConstants.method_channel_name,
            binaryMessenger: appDelegate.controller.binaryMessenger
        )
        
        acsChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
                case "joinCallClick":
                print("joinCallClick")
                self?.joinTeamsMeeting(result: result, args: call.arguments as! NSDictionary)
            case "startChat":
                self?.startChat(result: result, args: call.arguments as! NSDictionary)
            case "startAudioCall":
                self?.startAudioCall(result: result, args: call.arguments as! NSDictionary)
            case "startVideoCall":
               self?.startVideoCall(result: result, args: call.arguments as! NSDictionary)
                default:
                    result(FlutterMethodNotImplemented)
                    return
            }
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
        storageUserDefaults.set("", forKey: StorageKeys.bankerEmailId)
        teamsCallingViewController.startCall()

//        PIPKit.show(with: PIPACSViewController())
    }
    
    @objc func handleNotification(_ notification : NSNotification){
        print("handle the chat")
        let info = notification.userInfo
        let isVideoCall = info!["isVideo"] as! Bool
        let teamsVC = TeamsCallingViewController()
        teamsVC.startAudioVideoCall(isVideoCall: isVideoCall)
    }
    
    
    
    private func startChat (result: FlutterResult, args: NSDictionary) {
        let bankerEmailId = args.value(forKey: "user_name") as! String
        let chatController = ChatController(chatAdapter: nil, rootViewController: self.window?.rootViewController)
        chatController.bankerEmailId = "chantal@acsteamsciti.onmicrosoft.com"
        storageUserDefaults.set("chantal@acsteamsciti.onmicrosoft.com", forKey: StorageKeys.bankerEmailId)
        chatController.isForCall = false
        chatController.prepareChatComposite()
    }

    private func startAudioCall (result: FlutterResult, args: NSDictionary) {
        let bankerEmailId = args.value(forKey: "user_name") as! String
        let teamsCallingViewController = TeamsCallingViewController()
        storageUserDefaults.set("chantal@acsteamsciti.onmicrosoft.com", forKey: StorageKeys.bankerEmailId)
        teamsCallingViewController.startAudioVideoCall(isVideoCall: false)
    }
    
    private func startVideoCall (result: FlutterResult, args: NSDictionary) {
        let bankerEmailId = args.value(forKey: "user_name") as! String
        let teamsCallingViewController = TeamsCallingViewController()
        storageUserDefaults.set("chantal@acsteamsciti.onmicrosoft.com", forKey: StorageKeys.bankerEmailId)
        teamsCallingViewController.startAudioVideoCall(isVideoCall: true)
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

