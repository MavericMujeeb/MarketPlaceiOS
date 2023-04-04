//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum JoinCallType: Int, RawRepresentable, CustomStringConvertible {
    case groupCall
    case teamsMeeting
    case voiceCall

    var description: String {
        switch self {
        case .groupCall:
            return "Group call"
        case .teamsMeeting:
            return "Teams meeting"
        case .voiceCall:
            return "ACS Voice Call"
        }
    }
}
