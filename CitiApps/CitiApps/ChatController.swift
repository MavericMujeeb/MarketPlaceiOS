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
                token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmU3ODMxYTAwLWZlNTctNDkyNS1hMDZmLWZhYWY1ZTgwYzBkNF8wMDAwMDAxNy0zNjkxLWRmZWItZjg4My0wODQ4MjIwMGY2MzkiLCJzY3AiOjE3OTIsImNzaSI6IjE2Nzc1NjUzNzciLCJleHAiOjE2Nzc2NTE3NzcsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQiLCJyZXNvdXJjZUlkIjoiZTc4MzFhMDAtZmU1Ny00OTI1LWEwNmYtZmFhZjVlODBjMGQ0IiwicmVzb3VyY2VMb2NhdGlvbiI6InVuaXRlZHN0YXRlcyIsImlhdCI6MTY3NzU2NTM3N30.o08-g-_RSD6oCWOxpwIBhWjxjNTozK1dCmSXMr1pL1h6I8A9JOlTCgfYmbHnkjPy0BcK1ZaYBNet1j2WbfpYD-rhWOQ9fmJBfNjuE_AIebPJwcr_-vZFtjv3RpEsIZ8Wk3RksLLjE4JpuDDKSllkpAaIfU9qIjaDKE_At7gmHEGmLoDa6khQcSFHczhO_6Q1MMV1IkdJ3KO5C2w981AidJUREsZb9caPynE8i3QhgxkLVh4Mvo4qy0bOx0NUy870DIZ7GVS7eZLr0TiiEwfwGYcw_Zezbcrhij0R7uNF83u8CnyRisTn623jUHAXdmBvc9IZ3FVVjgAWtId2QCYCHg"
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
                        id: CommunicationUserIdentifier("8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-3691-dfeb-f883-08482200f639"),
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
        
        let communicationIdentifier = CommunicationUserIdentifier("8:acs:e7831a00-fe57-4925-a06f-faaf5e80c0d4_00000017-3691-dfeb-f883-08482200f639")
        
        
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:"eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOmU3ODMxYTAwLWZlNTctNDkyNS1hMDZmLWZhYWY1ZTgwYzBkNF8wMDAwMDAxNy0zNjkxLWRmZWItZjg4My0wODQ4MjIwMGY2MzkiLCJzY3AiOjE3OTIsImNzaSI6IjE2Nzc1NjUzNzciLCJleHAiOjE2Nzc2NTE3NzcsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQiLCJyZXNvdXJjZUlkIjoiZTc4MzFhMDAtZmU1Ny00OTI1LWEwNmYtZmFhZjVlODBjMGQ0IiwicmVzb3VyY2VMb2NhdGlvbiI6InVuaXRlZHN0YXRlcyIsImlhdCI6MTY3NzU2NTM3N30.o08-g-_RSD6oCWOxpwIBhWjxjNTozK1dCmSXMr1pL1h6I8A9JOlTCgfYmbHnkjPy0BcK1ZaYBNet1j2WbfpYD-rhWOQ9fmJBfNjuE_AIebPJwcr_-vZFtjv3RpEsIZ8Wk3RksLLjE4JpuDDKSllkpAaIfU9qIjaDKE_At7gmHEGmLoDa6khQcSFHczhO_6Q1MMV1IkdJ3KO5C2w981AidJUREsZb9caPynE8i3QhgxkLVh4Mvo4qy0bOx0NUy870DIZ7GVS7eZLr0TiiEwfwGYcw_Zezbcrhij0R7uNF83u8CnyRisTn623jUHAXdmBvc9IZ3FVVjgAWtId2QCYCHg") else {
            return
        }

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
