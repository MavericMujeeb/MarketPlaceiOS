//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public var loggedInUserName=""
public var loggedInUserId=""
public var communincationTokenString:String!

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    private(set) var themeOptions: ThemeOptions?
    private(set) var localizationOptions: LocalizationOptions?
    private(set) var displayName: String?
    private(set) var userId: String?

    private(set) var isAudioCall: Bool?
    private(set) var isVideoCall: Bool?
    private(set) var isIncomingCall: Bool?


    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    public init(theme: ThemeOptions? = nil,
                localization: LocalizationOptions? = nil, name:String!, userId:String!, token:String!, isAudio:Bool!, isVideo:Bool!, isIncomingCall:Bool!) {
        self.themeOptions = theme
        self.localizationOptions = localization
        self.displayName = name
        loggedInUserName = name
        loggedInUserId = userId
        //setting the token globally to use it for Chat
        communincationTokenString = token
        isAudioCall = isAudio
        isVideoCall = isVideo
    }
}
