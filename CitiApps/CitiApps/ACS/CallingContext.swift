//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//


import Foundation
import AzureCommunicationCalling
import AzureCommunicationUICalling

public typealias TokenFetcher = (@escaping (String?, Error?) -> Void) -> Void

final class CallingContext {
    // MARK: Constants
    private static let remoteParticipantsDisplayed: Int = 5

    // MARK: Properties
    private (set) var joinId: String!
    var displayName: String!
    var userId : String!
    private var tokenFetcher: TokenFetcher
    private var callComposite: CallComposite?

    var callType: JoinCallType = .groupCall
    var callChatToken: String!

    // MARK: Initialization

    init(tokenFetcher: @escaping TokenFetcher) {
        self.tokenFetcher = tokenFetcher
    }

    // MARK: Private function
    private func fetchInitialToken() async -> String? {
        return await withCheckedContinuation { continuation in
            tokenFetcher { token, error in
                if let error = error {
                    print("ERROR: Failed to fetch initial token. \(error.localizedDescription)")
                }
                continuation.resume(returning: token)
            }
        }
    }

    // MARK: Public API
    func getTokenCredential() async throws -> CommunicationTokenCredential {
            let token = await fetchInitialToken()
            callChatToken = token //<---- set the call chat token
            let tokenCredentialOptions = CommunicationTokenRefreshOptions(initialToken: token, refreshProactively: true, tokenRefresher: self.tokenFetcher)
            do {
                let tokenCredential = try CommunicationTokenCredential(withOptions: tokenCredentialOptions)
                return tokenCredential
            } catch {
                print("ERROR: It was not possible to create user credential.")
                throw error
            }
    }

    @MainActor
    func startCallComposite(_ joinConfig: JoinCallConfig) async {
        print("startCallComposite -> Clicked")
        let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let uuid = UUID(uuidString: joinIdStr) ?? UUID()
        let displayName = joinConfig.displayName
        print("startCallComposite 3-> Clicked")
        do {
            let communicationTokenCredential = try await getTokenCredential()
            print("startCallComposite 33-> Clicked")
            let callCompositeOptions = CallCompositeOptions(name: self.displayName, userId: self.userId, token: callChatToken)
            self.callComposite = CallComposite(withOptions: callCompositeOptions)
            print("startCallComposite 32-> Clicked")
            switch joinConfig.callType {
            case .groupCall:
                self.callComposite?.launch(
                    remoteOptions: RemoteOptions(
                        for: .groupCall(groupId: uuid),
                        credential: communicationTokenCredential,
                        displayName: displayName
                    )
                )
            case .audioCall:
                self.callComposite?.launch(
                    remoteOptions: RemoteOptions(
                        for: .audioCall(cAcsId: joinIdStr),
                        credential: communicationTokenCredential,
                        displayName: displayName
                    )
                )
            case .videoCall:
                self.callComposite?.launch(
                    remoteOptions: RemoteOptions(
                        for: .videoCall(cAcsId: joinIdStr),
                        credential: communicationTokenCredential,
                        displayName: displayName
                    )
                )
            case .teamsMeeting:
                self.callComposite?.launch(
                    remoteOptions: RemoteOptions(
                        for: .teamsMeeting(teamsLink: joinIdStr),
                        credential: communicationTokenCredential,
                        displayName: displayName
                    )
                )
            }
        } catch {
            print("ERROR: Cannot start or join a call due to user credential creating error: \(error.localizedDescription).")
        }
    }
    
    func startAudioVideoCall(_ joinConfig: JoinCallConfig) async {
        print("startAudioVideoCall -> Clicked")
        do {
            self.callChatToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjY0YTM4ZDUyLTMzZmItNDQwNy1hOGZhLWNiMzI3ZWZkZjdkNV8wMDAwMDAxNy1jMzVhLTU4YTgtYmNjOS0zZTNhMGQwMDhmOTciLCJzY3AiOjE3OTIsImNzaSI6IjE2Nzk5Mjc1NTciLCJleHAiOjE2ODAwMTM5NTcsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiI2NGEzOGQ1Mi0zM2ZiLTQ0MDctYThmYS1jYjMyN2VmZGY3ZDUiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc5OTI3NTU3fQ.raxpyUUag0hnrKxX_6Smex_zpJdc1r-2PzqM0z4yvefUgcVKp1tEHjkkzgpBaAzJ5yNNF0lfpxShLevhsA1drLfmbbnJ6-mxHa6AtFoXyFIwE3UGV2NSVYhBNuXDXtXUMkU78nbN09EbU4YpS4TBok_69hDOPJF037_tsLXXjHT49vbGQtGS_XEgA-Jja70m4bo89ElpD5_iXO6CAXorH5UB3BwfV0cqAzKgZjkJ02QRHAmV9u2LhdvcwlgLzIKJIV8bGgIbv4v7d_0JK6UyKM4-8hwfOaUZowRxK4yaJFffEKvnadZBfbzNzIQqIKoKY4FpMpmhLaYFzHY686Yf2A"
            let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            print("joinIdStr ->\(joinIdStr)")
            let communicationTokenCredential = try CommunicationTokenCredential(token: self.callChatToken)
            print("startAudioVideoCall -> Clicked2")
            let callCompositeOptions = CallCompositeOptions(name: self.displayName, userId: self.userId, token: self.callChatToken)
            self.callComposite = CallComposite(withOptions: callCompositeOptions)
            self.callComposite?.launch(
                remoteOptions: RemoteOptions(
                    for: .audioCall(cAcsId: joinIdStr),
                    credential: communicationTokenCredential,
                    displayName: displayName
                )
            )
            print("startAudioVideoCall -> Clicked3")
        } catch {
            print("startAudioVideoCall Error-> \(error)")
        }
    }
}
