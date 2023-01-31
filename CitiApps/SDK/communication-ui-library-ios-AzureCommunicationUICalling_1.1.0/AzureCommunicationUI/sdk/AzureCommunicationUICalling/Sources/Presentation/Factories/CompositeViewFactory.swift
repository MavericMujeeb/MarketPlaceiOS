//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeViewFactoryProtocol {
    func makeSetupView() -> SetupView
    func makeCallingView(teamsMeetingLink: String) -> CallingView
}

struct CompositeViewFactory: CompositeViewFactoryProtocol {
    private let logger: Logger
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let avatarManager: AvatarViewManagerProtocol
    private let videoViewManager: VideoViewManager

    init(logger: Logger,
         avatarManager: AvatarViewManagerProtocol,
         videoViewManager: VideoViewManager,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol) {
        self.logger = logger
        self.avatarManager = avatarManager
        self.videoViewManager = videoViewManager
        self.compositeViewModelFactory = compositeViewModelFactory
    }

    func makeSetupView() -> SetupView {
        return SetupView(viewModel: compositeViewModelFactory.getSetupViewModel(),
                         viewManager: videoViewManager,
                         avatarManager: avatarManager)
    }

    func makeCallingView(teamsMeetingLink: String) -> CallingView {
        return CallingView(viewModel: compositeViewModelFactory.getCallingViewModel(teamsMeetingLink: teamsMeetingLink),
                           avatarManager: avatarManager,
                           viewManager: videoViewManager)
    }
}
