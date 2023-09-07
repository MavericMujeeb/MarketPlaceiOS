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
        let joinIdStr = joinConfig.joinId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let uuid = UUID(uuidString: joinIdStr) ?? UUID()
        let displayName = joinConfig.displayName

        do {
            let communicationTokenCredential = try await getTokenCredential()
            
            let callCompositeOptions = CallCompositeOptions(name: self.displayName, userId: self.userId, token: callChatToken, isAudio: joinConfig.isAudioCall, isVideo: joinConfig.isVideoCall, isIncomingCall: false)
            self.callComposite = CallComposite(withOptions: callCompositeOptions)
                    
            switch joinConfig.callType {
            case .groupCall:
                self.callComposite?.launch(
                    remoteOptions: RemoteOptions(
                        for: .groupCall(groupId: uuid),
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
            case .voiceCall:
                self.callComposite?.launch(
                    remoteOptions: RemoteOptions(
                        for: .audioVideoCall(acsId: joinIdStr),
                        credential: communicationTokenCredential,
                        displayName: displayName
                    )
                )
            }
        } catch {
            print("ERROR: Cannot start or join a call due to user credential creating error: \(error.localizedDescription).")
        }
    }
}
