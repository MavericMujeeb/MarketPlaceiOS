//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum JoinCallType: Int, RawRepresentable, CustomStringConvertible {
    case groupCall
    case teamsMeeting
    case audioCall
    case videoCall

    var description: String {
        switch self {
        case .groupCall:
            return "Group call"
        case .audioCall:
            return "Audio call"
        case .videoCall:
            return "Video call"
        case .teamsMeeting:
            return "Teams meeting"
        }
    }
}
