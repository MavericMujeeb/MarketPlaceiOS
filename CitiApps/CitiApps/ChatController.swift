//
//  ChatController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 20/02/23.
//

import Foundation
import AzureCommunicationChat
import AzureCommunicationCommon


class ChatController {
    
    init(params:NSDictionary) {
        
        let endpoint = "https://acschatcallingdemo.communication.azure.com/"
        
        do{
            let credential = try CommunicationTokenCredential(
                token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjYxZmY4Yjg5LTY2ZjktNGMxYS04N2FkLTJlODI2MDc1MzdkNF8wMDAwMDAxNy0xM2ZiLWY0OTUtMDYzZC04ZTNhMGQwMDhhYTIiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzY5ODUxMjciLCJleHAiOjE2NzcwNzE1MjcsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiI2MWZmOGI4OS02NmY5LTRjMWEtODdhZC0yZTgyNjA3NTM3ZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc2OTg1MTI3fQ.qkbfDm8lKt0sb-lMmN-pzNX6d8o-iHNRvraX9GmRVNXpDE2Pl8eIPfpkPKF8eQeeY1pfb0k6DV9AsgZ-ibwxlLw-KYF6BUj2dk7K4OiMYFAEZLhelVK2Hc_EVd6h2iCCSYjfxJJyojO1vpzKjnaqjSjosLANDMMWim9bVBU6P0Lp7NlEwybaaDTVya6uvzIPyTmBrGhOKZ632HC0hvv5rL2KVqIBoDy34zAMhboskiybt28Vx76AXbTMq2TjUBUePNhGxhs9clpkQ_zBjt4KeVsa4U5Li23V8fRcsltCZsR6oj1XVTH10_7uiLTf-LPcwzzhANiLFpfoy1Zlx8yl5w"
            )
            let options = AzureCommunicationChatClientOptions()

            let chatClient = try ChatClient(
                endpoint: endpoint,
                credential: credential,
                withOptions: options
            )
            let request = CreateChatThreadRequest(
                topic: "Janet",
                participants: [
                    ChatParticipant(
                        id: CommunicationUserIdentifier("a2194b29-07bb-48bb-8607-6151334cf904"),
                        displayName: "Janet Johnson"
                    ),
                ]
            )

            var threadId: String?
            chatClient.create(thread: request) { result, _ in
                switch result {
                case let .success(result):
                    threadId = result.chatThread?.id

                case .failure:
                    print(result)
//                    fatalError("Failed to create thread.")
                }
            }
            print(threadId ?? "no thread id")
        }
        catch {
            //hanle the error
        }
        
    }
}
