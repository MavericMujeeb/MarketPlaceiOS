import Foundation
import UIKit

class ChatVS : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

////
////  ChatViewController.swift
////  CitiApps
////
////  Created by Balaji Babu Modugumudi on 27/01/23.
////
//
//import Foundation
//import AzureCommunicationChat
//import AzureCommunicationCommon
//import UIKit
//import AzureCore
//
//
//class ChatViewController : UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        // Do any additional setup after loading the view.
//
//        let semaphore = DispatchSemaphore(value: 0)
//        DispatchQueue.global(qos: .background).async {
//            do {
//                // <CREATE A CHAT CLIENT>
//                let endpoint = "https://mpteamsintg.communication.azure.com"
//
//                let credential =
//                try CommunicationTokenCredential(
//                    token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjdlOTRjMzVlLThjZGItNDhiOC04NDcyLTk2Njk4OWQ4NGZkMF8wMDAwMDAxNi05MjY5LTZjMTEtYzQwNS01NzQ4MjIwMGU4NmUiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzQ4MTEyNjIiLCJleHAiOjE2NzQ4OTc2NjIsInJnbiI6ImluIiwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjdlOTRjMzVlLThjZGItNDhiOC04NDcyLTk2Njk4OWQ4NGZkMCIsInJlc291cmNlTG9jYXRpb24iOiJpbmRpYSIsImlhdCI6MTY3NDgxMTI2Mn0.C_eQe1ab014tuFyqZJXgvxak2mV8EG87hzEyTEieAw2W7GDx4SeJJVs__f9oWm2avqFUj54uczOE4PO0wWdtyxRlukttPt4ko5RiBBAS8yY4FePiwd0ymxFJ5fbtVk1MEUm711oXVHlNYfxtMh_2UKD4luiGuJqCOCFW18WPgJCo9OIHgon3rPTQFoyhMag2-ccRyVldZAeoCJVhcF5T0flAwUYvl1GsrcX393Q2z-QT79kdDYzEkIGipaGtYkEwOzzrKdqI0eN-JK2QFA_Kor77k3VL6ytglxmbjLGkvPaRJL3BBUCmaGOzeEPDhunFTJGvX4WhK5t0TbmlLhyLdw"
//                )
//                let options = AzureCommunicationChatClientOptions()
//
//                let chatClient = try ChatClient(
//                    endpoint: endpoint,
//                    credential: credential,
//                    withOptions: options
//                )
//
//                // <CREATE A CHAT THREAD>
//                let request = CreateChatThreadRequest(
//                    topic: "Quickstart",
//                    participants: [
//                        ChatParticipant(
//                            id: CommunicationUserIdentifier("a593cb83-4283-43b5-9b32-a62e44c9cd72"),
//                            displayName: "Jack"
//                        )
//                    ]
//                )
//
//                var threadId: String?
//                chatClient.create(thread: request) { result, _ in
//                    switch result {
//                    case let .success(result):
//                        threadId = result.chatThread?.id
//
//                    case .failure:
//                        fatalError("Failed to create thread.")
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//
//                // <LIST ALL CHAT THREADS>
//                chatClient.listThreads { result, _ in
//                    switch result {
//                    case let .success(chatThreadItems):
//                        var iterator = chatThreadItems.syncIterator
//                            while let chatThreadItem = iterator.next() {
//                                print("Thread id: \(chatThreadItem.id)")
//                            }
//                    case .failure:
//                        print("Failed to list threads")
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//
//                // <GET A CHAT THREAD CLIENT>
//                let chatThreadClient = try chatClient.createClient(forThread: threadId!)
//
//                // <SEND A MESSAGE>
//                let message = SendChatMessageRequest(
//                    content: "Hello!",
//                    senderDisplayName: "Jack"
//                )
//
//                var messageId: String?
//
//                chatThreadClient.send(message: message) { result, _ in
//                    switch result {
//                    case let .success(result):
//                        print("Message sent, message id: \(result.id)")
//                        messageId = result.id
//                    case .failure:
//                        print("Failed to send message")
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//
//                // <SEND A READ RECEIPT >
//                if let id = messageId {
//                    chatThreadClient.sendReadReceipt(forMessage: id) { result, _ in
//                        switch result {
//                        case .success:
//                            print("Read receipt sent")
//                        case .failure:
//                            print("Failed to send read receipt")
//                        }
//                        semaphore.signal()
//                    }
//                    semaphore.wait()
//                } else {
//                    print("Cannot send read receipt without a message id")
//                }
//
//                // <RECEIVE MESSAGES>
//                chatThreadClient.listMessages { result, _ in
//                    switch result {
//                    case let .success(messages):
//                        var iterator = messages.syncIterator
//                        while let message = iterator.next() {
//                            print("Received message of type \(message.type)")
//                        }
//
//                    case .failure:
//                        print("Failed to receive messages")
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//
//                // <ADD A USER>
//                let user = ChatParticipant(
//                    id: CommunicationUserIdentifier("<USER_ID>"),
//                    displayName: "Jane"
//                )
//
//                chatThreadClient.add(participants: [user]) { result, _ in
//                    switch result {
//                    case let .success(result):
//                        if let errors = result.invalidParticipants, !errors.isEmpty {
//                            print("Error adding participant")
//                        } else {
//                            print("Added participant")
//                        }
//                    case .failure:
//                        print("Failed to add the participant")
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//
//                // <LIST USERS>
//                chatThreadClient.listParticipants { result, _ in
//                    switch result {
//                    case let .success(participants):
//                        var iterator = participants.syncIterator
//                        while let participant = iterator.next() {
//                            let user = participant.id as! CommunicationUserIdentifier
//                            print("User with id: \(user.identifier)")
//                        }
//                    case .failure:
//                        print("Failed to list participants")
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//            } catch {
//                print("Quickstart failed: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
