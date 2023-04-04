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


class ChatController  {
    
    var commServEndPointURL:String! = "https://acscallchatcomserv.communication.azure.com/"
    var chatAdapter: ChatAdapter?
    var threadId:String! = "19:064b68041bc84b8b8892ebc75002b7d3@thread.v2"
    var bankerAcsId:String! = "8:acs:64a38d52-33fb-4407-a8fa-cb327efdf7d5_00000017-c355-9a77-71bf-a43a0d0088eb"
    var bankerUserToken:String! = ""
    var bankerUserName:String! = "Chantal Kendall"
    var custAcsId:String! = "8:acs:64a38d52-33fb-4407-a8fa-cb327efdf7d5_00000017-c35a-58a8-bcc9-3e3a0d008f97"
    var custUserToken:String! = ""
    var custUserName:String! = "Janet Johnson"
    var rootViewController : UIViewController!
    
    var isForCall:Bool = false
    
    init(chatAdapter: ChatAdapter? = nil, rootViewController: UIViewController!) {
        self.rootViewController = rootViewController
    }
    
    func prepareChatComposite() {
        self.callUserTokenAPI()
    }
    
    func initializeChatComposite() {
        
        do{
            let credential = try CommunicationTokenCredential(
                token: self.bankerUserToken
            )
            let options = AzureCommunicationChatClientOptions()

            let chatClient = try ChatClient(
                endpoint: self.commServEndPointURL,
                credential: credential,
                withOptions: options
            )
            let request = CreateChatThreadRequest(
                topic: "30-min meeting",
                participants: [
                    ChatParticipant(
                        id: CommunicationUserIdentifier(self.bankerAcsId),
                        displayName: self.bankerUserName
                    ),
                ]
            )

            chatClient.create(thread: request) { result, _ in
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
        let fullUrl: String = "https://acscallchattokenfunc.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
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
}
