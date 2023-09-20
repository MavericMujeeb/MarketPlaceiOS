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

class AzureChatController  {
    
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
    
    private func fetchAcsDetailsAndToken (completion: @escaping (Bool?, Error?)->Void) {
        NetworkManager.shared.getAcsParticipantDetails { response, error in
            if(error == nil){
                CircleLoader.sharedInstance.hide()
                
                self.bankerUserName = response?.originator?.participantName
                self.bankerAcsId = response?.originator?.acsId
                self.custUserName = response?.participantList?[0].participantName
                self.custAcsId = response?.participantList?[0].acsId
                self.threadId = response?.originator?.threadId
                
                let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
               
                guard let url = try? URL(string: fullUrl) else {
                    return
                }
                
                NetworkManager.shared.getACSUserDetails(url: fullUrl) { response, error in
                    CircleLoader.sharedInstance.hide()
                    if(error == nil){
                        self.custUserToken = response?.customerUserToken
                        self.bankerUserToken = response?.bankerUserToken
                        completion(true, nil)
                    }
                }
            }
            else{
                completion(nil, error)
            }
        }
    }
    
    func startChatComposite(completion: @escaping (Bool?)->Void) {
        fetchAcsDetailsAndToken { result, error in
            if(result == true){
                self.initChatClient(completion: completion)
            }
        }
    }
    
    func initChatClient(completion: @escaping (Bool?)->Void) {
        do{
            if(chatClient == nil){
                registerChatClient()
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
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
        catch {
            completion(false)
        }
    }
    
    func prepareChatComposite() {
        self.fetchAcsParticipantDetails()
    }

    private func initChatClient(){
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        NetworkManager.shared.getACSUserDetails(url: fullUrl) { acsUserResponse, error in
            CircleLoader.sharedInstance.hide()
            
            if(error == nil) {
                self.custUserToken = acsUserResponse?.customerUserToken
                self.bankerUserToken = acsUserResponse?.bankerUserToken
                self.registerChatClient()
            }
        }
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
                    print("start chat push notifications success")
                case let .failure(error):
                    print("start chat push notifications fail")
                    print(error.message)
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
        catch {
            print("registerChatClient error")
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
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
            
            if self.isForCall {
                //TODO::
            } else {
                let chatCompositeViewController = ChatCompositeViewController(
                    with: chatAdapter)
                let navController = UINavigationController(rootViewController: chatCompositeViewController)
                navController.modalPresentationStyle = .pageSheet
                self.rootViewController.present(navController, animated: true)
            }
        }
    }
    
    func fetchAcsParticipantDetails() {
        CircleLoader.sharedInstance.show()
        
        NetworkManager.shared.getAcsParticipantDetails { response, error in
            CircleLoader.sharedInstance.hide()
            self.bankerUserName = response?.originator?.participantName
            self.bankerAcsId = response?.originator?.acsId
            self.custUserName = response?.participantList?[0].participantName
            self.custAcsId = response?.participantList?[0].acsId
            self.threadId = response?.originator?.threadId
            
            self.fetchAcsUserToken()

        }
    }
    
    func fetchAcsUserToken() {
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        NetworkManager.shared.getACSUserDetails(url: fullUrl) { response, error in
            CircleLoader.sharedInstance.hide()
            if(error == nil){
                self.custUserToken = response?.customerUserToken
                self.bankerUserToken = response?.bankerUserToken
                self.initializeChatComposite()
            }
        }
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
