//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct CallConfiguration {
    let groupId: UUID?
    let meetingLink: String?
    let acsId: String?
    let compositeCallType: CompositeCallType
    let credential: CommunicationTokenCredential
    let displayName: String?
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
        case let .audioCall(cAcsId: meetingLink):
            self.groupId = nil
            self.meetingLink = nil
            self.acsId = meetingLink
            self.meetingLink = meetingLink
            self.compositeCallType = .audioCall
        case let .videoCall(cAcsId: meetingLink):
            self.groupId = nil
            self.meetingLink = meetingLink
            self.acsId = meetingLink
            self.compositeCallType = .videoCall
        case let .teamsMeeting(teamsLink: meetingLink):
            self.groupId = nil
            self.acsId = nil
            self.meetingLink = meetingLink
            self.compositeCallType = .teamsMeeting
        }
        self.credential = credential
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case audioCall
    case videoCall
    case teamsMeeting
}
