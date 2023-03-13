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
    
    var chatAdapter: ChatAdapter?
    var threadId:String! = "19:06914d05bcf14ebf820ec38aa47aa171@thread.v2"
    var bankerAcsId:String! = "8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-5da6-8610-6763-563a0d009051"
    var bankerUserToken:String! = ""
    var bankerUserName:String! = "Chantal Kendall"
    var custAcsId:String! = "8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-5da6-e2ec-740a-113a0d0081f2"
    var custUserToken:String! = ""
    var custUserName:String! = "Janet Johnson"
    var rootViewController : UIViewController!
    
    init(chatAdapter: ChatAdapter? = nil, rootViewController: UIViewController!) {
        self.rootViewController = rootViewController
    }
    
    func prepareChatComposite() {
        self.callUserTokenAPI()
    }
    
    func initializeChatComposite() {
        let endpoint = "https://acscallingchatcomserv.communication.azure.com/"
        
        do{
            let credential = try CommunicationTokenCredential(
                token: self.bankerUserToken
            )
            let options = AzureCommunicationChatClientOptions()

            let chatClient = try ChatClient(
                endpoint: endpoint,
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
        print(self.threadId)

        self.chatAdapter = ChatAdapter(
            endpoint: "https://acscallingchatcomserv.communication.azure.com/",
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
            let chatCompositeViewController = ChatCompositeViewController(
                with: chatAdapter)
            let navController = UINavigationController(rootViewController: chatCompositeViewController)
            navController.modalPresentationStyle = .pageSheet
            self.rootViewController.present(navController, animated: true)
        }
    }
    
    func callUserTokenAPI() {
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acscallingchatfunc.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
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
