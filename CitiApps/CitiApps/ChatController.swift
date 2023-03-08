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
    var threadId:String! = "19:d5a8fd9e7b2c40f09a64dc9ad8ab90ad@thread.v2"
    var bankerAcsId:String! = "8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-5da6-8610-6763-563a0d009051"
    var bankerUserToken:String! = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmU3ODMxYTAwLWZlNTctNDkyNS1hMDZmLWZhYWY1ZTgwYzBkNF8wMDAwMDAxNy01ZGE2LTg2MTAtNjc2My01NjNhMGQwMDkwNTEiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzgyMzYyMTkiLCJleHAiOjE2NzgzMjI2MTksInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiJlNzgzMWEwMC1mZTU3LTQ5MjUtYTA2Zi1mYWFmNWU4MGMwZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc4MjM2MjE5fQ.MC4gjwvUfNxVE6LPZauzRIaVQGANVmKLMRwHlGFmx4Z7eXlcqXGb3aspSLkVs18fozDh4BgortMYnEsV9oUo9JRQUnT59a3YN5TKxspziFELQwD2v1ad60PtE8v5bppS8OIAjNFmIFZpEIArnOHL3pPm6qwhbiHkgFLFpknA_KHc6ou3BWinQsjl9bh6v59x03es7OYNwQcavuGQhffiew3ujvfXM15ALJD1bZNsOTTv4WlmdEvqvoGQkWi4QJSocyZdx_ELN8bUq9S8dwIhJp7_rwoRO-zKFkacujuILRkmGkIJFKoIWZegLpQJRKNTZfjBM726zr3A_yeORllYeQ"
    var custAcsId:String! = "8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-5da6-e2ec-740a-113a0d0081f2"
    var custUserToken:String! = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmU3ODMxYTAwLWZlNTctNDkyNS1hMDZmLWZhYWY1ZTgwYzBkNF8wMDAwMDAxNy01ZGE2LWUyZWMtNzQwYS0xMTNhMGQwMDgxZjIiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzgyMzYyMTkiLCJleHAiOjE2NzgzMjI2MTksInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiJlNzgzMWEwMC1mZTU3LTQ5MjUtYTA2Zi1mYWFmNWU4MGMwZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc4MjM2MjE5fQ.HGSA_r6Ynt1ehIFsJOt15leslSP86z0aWYn71n0T3frGbjM3J3TgcUX_zK0D0KzrILm0O9QRjS5iPKBIh8S7buUBXDcPsaxwmJ6ISz2zu2C3BC9D6QuGxsGsdPCaG9leFlByxm9Gj-lVRuy8rKllxf0QCvNLLCFTwUI99Fn0CkZqUACPCLqae7yWreGBiRcE_l5RSN_9Sw31Ti7IWXta-kNzTCbsE9i3FbrdBEEdgxHiHIs6-gA4s0uWErMnhfitZkwZLeseEx1wa9ClBTOb2Q--YOrGdHpc5ze4u31XPc3D3Gqjx4XCq2HVfzS4ihbiSVnKKyTuEX1vgZhgQBbHgA"
    var rootViewController : UIViewController!
    
    init(chatAdapter: ChatAdapter? = nil, rootViewController: UIViewController!) {
        self.rootViewController = rootViewController
    }
    
    func prepareChatComposite() {
        initializeChatComposite()
    }
    
    func initializeChatComposite() {
        let endpoint = "https://acscallingchatcomserv.communication.azure.com/"
        
        do{
            let credential = try CommunicationTokenCredential(
                token: self.custUserToken
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
                        id: CommunicationUserIdentifier(self.custAcsId),
                        displayName: "Janet Johnson"
                    ),
                ]
            )

            chatClient.create(thread: request) { result, _ in
                switch result {
                case let .success(result):
                    print("Thread ID")
                    print(result)
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
        
        let communicationIdentifier = CommunicationUserIdentifier(self.bankerAcsId)
        
        
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:self.bankerUserToken) else {
            return
        }
        print(self.threadId)

        self.chatAdapter = ChatAdapter(
            endpoint: "https://acscallingchatcomserv.communication.azure.com/",
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: self.threadId,
            displayName: "Chantal Kandall")

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
    
    func callUserTokenAPI(){
        guard let url = URL(string: "https://acscallingchatfunc.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId=\(self.bankerAcsId)&customerAcsId=\(self.custAcsId)") else{
            return
        }

        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(AcsUserIdToken.self, from: data)
                    self.custUserToken = responseModel.customerUserToken
                    self.bankerUserToken = responseModel.bankerUserToken
                    print("Response Data json -> ")
                    print(self.custUserToken)
                    print(self.bankerUserToken)
                    DispatchQueue.main.async {
                        self.initializeChatComposite()
                    }
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
