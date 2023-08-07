//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureCommunicationChat

var acs_users = [
    "6959db5c-bf24-427e-94ee-42c208ec5878": ["name":"Richard Jones","userid":"6959db5c-bf24-427e-94ee-42c208ec5878"]
]

extension ChatParticipant {
    func toParticipantInfoModel(_ localParticipantId: String) -> ParticipantInfoModel {
        var displayName = ""
        var isLocalParticipant = true
        
        if(acs_users[id.stringValue] != nil){
            displayName = acs_users[id.stringValue]?["name"] ?? "Unknown user"
            isLocalParticipant = false
        }
        
        return ParticipantInfoModel(
            identifier: self.id,
            displayName: self.displayName ?? displayName,
            isLocalParticipant: isLocalParticipant,
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}

extension SignalingChatParticipant {
    func toParticipantInfoModel(_ localParticipantId: String) -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id!,
            displayName: self.displayName ?? "Unknown user",
            isLocalParticipant: id?.rawId == localParticipantId,
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}
