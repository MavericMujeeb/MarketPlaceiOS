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
    var threadId:String!
    var rootViewController : UIViewController!
    
    init(chatAdapter: ChatAdapter? = nil, rootViewController: UIViewController!) {
        self.rootViewController = rootViewController
    }
    
    func prepareChatComposite() {
        let endpoint = "https://acscallingchatcomserv.communication.azure.com/"
        
        do{
            let credential = try CommunicationTokenCredential(
                token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmU3ODMxYTAwLWZlNTctNDkyNS1hMDZmLWZhYWY1ZTgwYzBkNF8wMDAwMDAxNy0zYzQ5LTAwMTgtZTNjNy01OTNhMGQwMDg0MGIiLCJzY3AiOjE3OTIsImNzaSI6IjE2Nzc2NjEyNjQiLCJleHAiOjE2Nzc3NDc2NjQsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQiLCJyZXNvdXJjZUlkIjoiZTc4MzFhMDAtZmU1Ny00OTI1LWEwNmYtZmFhZjVlODBjMGQ0IiwicmVzb3VyY2VMb2NhdGlvbiI6InVuaXRlZHN0YXRlcyIsImlhdCI6MTY3NzY2MTI2NH0.OGV9G4LPtTCXsO7HK0qnIACw4T5-uBJ-DhoU86gReJ1uKZunylApJZLTPJBcrp1wmj5co6Bnn7dlCJjr3iAI48PzYA3-m2Ot60dQQT1of4-R7b7wD_fzg6-66wDHv78tSvjIeilrHe6wnmurQRUNd0v1JYTBeeBuqXAcv7o7oaFz8YC1gcyA5rL29y9KBzdsJYfkfQZINupLjmSL7rQ6LNaLea77BJ_TRYJAOZs1JAnzi6N7eDr5dDnDICwvtU8D-MMkUqsgGr24K3n6r_mOV6GJXRxYTaR7BeqK1jFumyXYFv97jEM9Gwmbd_w5FBJ6ggD091SCoZIzZDq8BLsY8A"
            )
            let options = AzureCommunicationChatClientOptions()

            let chatClient = try ChatClient(
                endpoint: endpoint,
                credential: credential,
                withOptions: options
            )
            let request = CreateChatThreadRequest(
                topic: "Adhoc Chat Demo",
                participants: [
                    ChatParticipant(
                        id: CommunicationUserIdentifier("8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-3c49-0018-e3c7-593a0d00840b"),
                        displayName: "Janet Johnson"
                    ),
                ]
            )

            chatClient.create(thread: request) { result, _ in
                switch result {
                case let .success(result):
                    self.threadId = result.chatThread?.id
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
        
        let communicationIdentifier = CommunicationUserIdentifier("8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-3c49-0018-e3c7-593a0d00840b")
        
        
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:"eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmU3ODMxYTAwLWZlNTctNDkyNS1hMDZmLWZhYWY1ZTgwYzBkNF8wMDAwMDAxNy0zYzQ5LTAwMTgtZTNjNy01OTNhMGQwMDg0MGIiLCJzY3AiOjE3OTIsImNzaSI6IjE2Nzc2NjEyNjQiLCJleHAiOjE2Nzc3NDc2NjQsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQiLCJyZXNvdXJjZUlkIjoiZTc4MzFhMDAtZmU1Ny00OTI1LWEwNmYtZmFhZjVlODBjMGQ0IiwicmVzb3VyY2VMb2NhdGlvbiI6InVuaXRlZHN0YXRlcyIsImlhdCI6MTY3NzY2MTI2NH0.OGV9G4LPtTCXsO7HK0qnIACw4T5-uBJ-DhoU86gReJ1uKZunylApJZLTPJBcrp1wmj5co6Bnn7dlCJjr3iAI48PzYA3-m2Ot60dQQT1of4-R7b7wD_fzg6-66wDHv78tSvjIeilrHe6wnmurQRUNd0v1JYTBeeBuqXAcv7o7oaFz8YC1gcyA5rL29y9KBzdsJYfkfQZINupLjmSL7rQ6LNaLea77BJ_TRYJAOZs1JAnzi6N7eDr5dDnDICwvtU8D-MMkUqsgGr24K3n6r_mOV6GJXRxYTaR7BeqK1jFumyXYFv97jEM9Gwmbd_w5FBJ6ggD091SCoZIzZDq8BLsY8A") else {
            return
        }
        print(self.threadId)

        self.chatAdapter = ChatAdapter(
            endpoint: "https://acscallingchatcomserv.communication.azure.com/",
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: self.threadId,
            displayName: "Janet Johnson")

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
}
