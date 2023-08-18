//
//  ChatController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 20/02/23.
//

import Foundation
import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCommunicationUIChat
import UIKit

var chatClient: ChatClient?

class ChatController  {
    
    var commServEndPointURL:String! = "https://acscomunicationservice.communication.azure.com/"
    var chatAdapter: ChatAdapter?
    var threadId:String! = ""
    var bankerAcsId:String! = ""
    var bankerUserToken:String! = ""
    var bankerEmailId:String! = ""
    var bankerUserName:String! = ""
    var custAcsId:String! = ""
    var custUserToken:String! = ""
    var custUserName:String! = UserDefaults.standard.string(forKey: "loginUserName")
    var rootViewController : UIViewController!
    
    var isForCall:Bool = false
    
    init(chatAdapter: ChatAdapter? = nil, rootViewController: UIViewController!) {
        self.rootViewController = rootViewController
    }
    
    func prepareChatComposite() {
        self.callParticipantDetailsAPI()
    }

    func initChatClient(){
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
        guard let url = try? URL(string: fullUrl) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            CircleLoader.sharedInstance.hide()
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(AcsUserIdToken.self, from: data)
                    self.custUserToken = responseModel.customerUserToken
                    self.bankerUserToken = responseModel.bankerUserToken
                    self.registerChatClient()
                } catch {
                    print("Response Data error -> ")
                    print(error)
                }
                print("Response Data string -> ")
                print(string)
            }
        }
        task.resume()
    }
    
    func registerChatClient() {
        do{
            let credential = try CommunicationTokenCredential(
                token: self.bankerUserToken
            )
            let options = AzureCommunicationChatClientOptions()
            
            chatClient = try ChatClient(
                endpoint: self.commServEndPointURL,
                credential: credential,
                withOptions: options
            )
            
            let appPubs = (UIApplication.shared.delegate as! AppDelegate).appPubs
            let token = appPubs.pushToken

            let semaphore = DispatchSemaphore(value: 0)

            chatClient?.startPushNotifications(deviceToken: (token?.hexString)!) { result in
                switch result {
                case .success:
                    print("startPushNotifications success")
//                    chatClient?.register(event: .chatMessageReceived, handler: { response in
//                        switch response {
//                        case let .chatMessageReceivedEvent(event):
//                            print("Received a message ---- 12121212: \(event.message)")
//                        default:
//                            return
//                        }
//                    })
                case let .failure(error):
                    print("Add the code to do things when you failed to start Push Notifications")
                    print(error.message)
                }
                semaphore.signal()
            }
            semaphore.wait()
            
//            print("chatClient?.startRealTimeNotifications")
//            chatClient?.startRealTimeNotifications{result in
//                switch result {
//                    case .success:
//                    print("chatClient?.success")
//                        chatClient?.register(event: .chatMessageReceived, handler: { response in
//                            print("chatMessageReceived -- response")
//                            switch response {
//                            case let .chatMessageReceivedEvent(event):
//                                print("Received a message: \(event.message)")
//
//                                // create the alert
//                                let alert = UIAlertController(title: "New Message", message: event.message, preferredStyle: UIAlertController.Style.alert)
//
//                                // add the actions (buttons)
//                                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {action in
//                                    self.rootViewController?.dismiss(animated: true)
//                                }))
//
//                                alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.destructive, handler: {action in
//
//                                    self.rootViewController?.dismiss(animated: true)
//                                    //open chat screen
//                                    let storageUserDefaults = UserDefaults.standard
//                                    var bankerEmailId = storageUserDefaults.value(forKey: StorageKeys.bankerEmailId) as! String
//
//                                    self.bankerEmailId = bankerEmailId
//                                    self.isForCall = false
//                                    self.prepareChatComposite()
//
//                                }))
//                                // show the alert
//                                self.rootViewController?.present(alert, animated: true)
//                            default:
//                                return
//                            }
//                        })
//                    case .failure:
//                        print("Failed to start real-time notifications.")
//                    }
//            }
        }
        catch {
            print("init eroor")
            //hanle the error
        }
    }
    
    func initializeChatComposite() {
        
        do{
            if(chatClient == nil){
                initChatClient()
            }
            
            let request = CreateChatThreadRequest(
                topic: "30-min meeting",
                participants: [
                    ChatParticipant(
                        id: CommunicationUserIdentifier(self.bankerAcsId),
                        displayName: self.bankerUserName
                    ),
                ]
            )
            
            chatClient?.create(thread: request) { result, _ in
                switch result {
                case let .success(result):
                    self.startChatComposite()
                case .failure:
                    print(result)
                }
            }
        }
        catch {
            //hanle the error
        }
    }
    
    func startChatComposite() {
        
        let communicationIdentifier = CommunicationUserIdentifier(self.custAcsId)
        
        
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:self.custUserToken) else {
            return
        }
        
        self.chatAdapter = ChatAdapter(
            endpoint: self.commServEndPointURL,
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: self.threadId,
            displayName: self.custUserName)
        
        Task { @MainActor in
            guard let chatAdapter = self.chatAdapter else {
                return
            }
            chatAdapter.connect(completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.chatAdapter = nil
                    print("success -- chatadapter")
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
            if self.isForCall {
                //                let chatCompositeViewController = StartCallViewController()
                //                chatCompositeViewController.displayName = custUserName
                //                let navController = UINavigationController(rootViewController: chatCompositeViewController)
                //                navController.modalPresentationStyle = .pageSheet
                //                self.rootViewController.present(navController, animated: true)
                //
                //                Task { @MainActor in
                //                    let callConfig = JoinCallConfig(joinId: "", displayName: "", callType: .groupCall)
                //                    await self.callingContext.startCallComposite(callConfig)
                //                }
                
                
            } else {
                let chatCompositeViewController = ChatCompositeViewController(
                    with: chatAdapter)
                let navController = UINavigationController(rootViewController: chatCompositeViewController)
                navController.modalPresentationStyle = .pageSheet
                self.rootViewController.present(navController, animated: true)
            }
        }
    }
    
    func callUserTokenAPI() {
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
        guard let url = try? URL(string: fullUrl) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            CircleLoader.sharedInstance.hide()
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(AcsUserIdToken.self, from: data)
                    self.custUserToken = responseModel.customerUserToken
                    self.bankerUserToken = responseModel.bankerUserToken
                    self.initializeChatComposite()
                } catch {
                    print("Response Data error -> ")
                    print(error)
                }
                print("Response Data string -> ")
                print(string)
            }
        }
        task.resume()
    }
    
    func callParticipantDetailsAPI() {
        CircleLoader.sharedInstance.show()
        
        let reqBody = "{" +
        "\"originatorId\":\"\(self.bankerEmailId!)\"," +
        "\"participantName\":\"\(self.custUserName!)\"" +
        "}"

        let fullUrl: String = ACSResources.acs_chat_participantdetails_api
        
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = reqBody.data(using: .utf8)!
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            CircleLoader.sharedInstance.hide()
            
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ParticipantDetails.self, from: data)
                    self.bankerUserName = responseModel.originator?.participantName
                    self.bankerAcsId = responseModel.originator?.acsId
                    self.custUserName = responseModel.participantList?[0].participantName
                    self.custAcsId = responseModel.participantList?[0].acsId
                    self.threadId = responseModel.participantList?[0].threadId
                    self.callUserTokenAPI()
                } catch {
                    print("Response Data error -> ")
                    print(error)
                }
                print("Response Data string -> ")
                print(string)
            }
        }
        task.resume()
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        print("hexString")
        return hexString
    }
}
