//
//  ContentViewModel.swift
//  CallingWithChat
//
//  Created by Emlyn Bolton-Maggs on 2023-01-30.
//

import SwiftUI
import UIKit

import AzureCommunicationUIChat
import AzureCommunicationUICalling
import AzureCommunicationCommon

class ContentViewModel: ObservableObject {
    @Published var chatAdapter: ChatAdapter?
    @Published var callViewController: UIViewController?

    private let endpoint = "https://acschatcallingdemo.communication.azure.com/"
    private let identifier = "a2194b29-07bb-48bb-8607-6151334cf904"
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjYxZmY4Yjg5LTY2ZjktNGMxYS04N2FkLTJlODI2MDc1MzdkNF8wMDAwMDAxNi1hOTI0LTU0NmMtZjBhNy05MjNhMGQwMGUyNjgiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzUxOTI2MTAiLCJleHAiOjE2NzUyNzkwMTAsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQsdm9pcCIsInJlc291cmNlSWQiOiI2MWZmOGI4OS02NmY5LTRjMWEtODdhZC0yZTgyNjA3NTM3ZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc1MTkyNjEwfQ.aOMHf6QjvmVc5kyM4xOTNbF4QPc4eKQreRNer5n1x76bFvraKd6W1K6RDzWFumsQ-Ma2bmk8A4C0tbICXbjvwbTp69I4VEKZFGtpSBMAxFOn41l6E5KC2VKYtJ06qEFiK6ugzOE__sHYTaNseXyXQejqnv3BHM-eSFeBDQtbAfGkp-ltdxmICoeeloaAa-aYY4VZqCc0qoC2wXGDjLPRH8AMB0xK1qtJUEVvPGI2_9bEY8ZJAOOJZglnlNMmyOwTX6DGW-JzEUocUBuZEN6submY4r77Id7oKeB9z-vr4M_Am8NY9c-m_gitXXeUi1pf_jmP_4qm1kdj7VY8gDRN2g"
    private let chatThreadId = "19%3ameeting_YTdiNGQ2YzktMTA3Mi00NTQyLWFjYWYtOTYzYzY2ZDVlNjY3%40thread.v2"
    private let groupCallId = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_YmZhMDUxNzgtZDM3MS00NWI3LTk3ZmEtNzZkODMwYzYyMjA2%40thread.v2/0?context=%7b%22Tid%22%3a%221987bc45-e629-47d3-9326-b5300dd15e34%22%2c%22Oid%22%3a%224e94fb79-0528-4ce7-ad31-9192706b32c3%22%7d"

    func createChatAdapter() async {
        let adapter = ChatAdapter(
            endpoint: endpoint,
            identifier: CommunicationUserIdentifier(identifier),
            credential: try! CommunicationTokenCredential(token: token),
            threadId: chatThreadId
        )
        self.chatAdapter = adapter
        do {
            chatAdapter!.connect(completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.chatAdapter = nil
                    print("success -- chatadapter")
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
            Task { @MainActor in
                self.chatAdapter = adapter
            }
        } catch {
            print(error)
        }
    }
    

    func startVideoCall() {
        let composite = CallComposite()
        let vc = composite.getViewController(
            remoteOptions: RemoteOptions(
                for: .teamsMeeting(teamsLink: groupCallId),
                credential: try! CommunicationTokenCredential(token: token),
                displayName: "Balaji"
            )
        )
        Task { @MainActor in
            self.callViewController = vc
        }
    }
}
