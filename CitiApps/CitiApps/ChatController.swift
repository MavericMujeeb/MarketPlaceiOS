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
    
    func callParticipantDetailsAPI() {
        CircleLoader.sharedInstance.show()
        let reqBody = "{" +
        "\"originatorId\":\"\(self.bankerEmailId!)\"," +
        "\"participantName\":\"\(self.custUserName!)\"" +
        "}"
        
        let fullUrl: String = "https://service-20230322105302607.azurewebsites.net/api/participantDetails"
        
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
