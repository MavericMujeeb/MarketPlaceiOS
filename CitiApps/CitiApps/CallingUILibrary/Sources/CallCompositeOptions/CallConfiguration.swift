//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling

struct CallConfiguration {
    let groupId: UUID?
    let meetingLink: String?
    let compositeCallType: CompositeCallType
    let credential: CommunicationTokenCredential
    let displayName: String?
    let acsId:String?
    let diagnosticConfig: DiagnosticConfig

    init(locator: JoinLocator,
         credential: CommunicationTokenCredential,
         displayName: String?) {
        switch locator {
        case let .groupCall(groupId: groupId):
            self.groupId = groupId
            self.meetingLink = nil
            self.acsId = nil
            self.compositeCallType = .groupCall
        case let .teamsMeeting(teamsLink: meetingLink):
            self.groupId = nil
            self.meetingLink = meetingLink
            self.acsId = nil
            self.compositeCallType = .teamsMeeting
        case let .audioVideoCall(acsId: acsUserId):
            self.groupId = nil
            self.meetingLink = ""
            self.acsId = acsUserId
            self.compositeCallType = .audioVideoMeeting
        case .incomingCall:
            self.groupId = nil
            self.meetingLink = ""
            self.acsId = nil
            self.compositeCallType = .incomingCallAudioVideoMeeting
        }
        self.credential = credential
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    case audioVideoMeeting
    case incomingCallAudioVideoMeeting
}
