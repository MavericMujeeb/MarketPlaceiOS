//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class BottomBarViewModel: ObservableObject {
    
    @State var showFilePicker = false
    @State var added = false
    
    private let logger: Logger
    private let dispatch: ActionDispatch

    var sendButtonViewModel: IconButtonViewModel!
    var attachmentButtonViewModel: IconButtonViewModel!
    


    // MARK: Typing Indicators
    private var lastTypingIndicatorSendTimestamp = Date()
    private let typingIndicatorDelay: TimeInterval = 8.0

    @Published var isLocalUserRemoved: Bool = false
    @Published var message: String = "" {
        didSet {
            sendButtonViewModel.update(isDisabled: message.isEmptyOrWhiteSpace)
            sendButtonViewModel.update(iconName: message.isEmptyOrWhiteSpace ? .sendDisabled : .send)
            guard !message.isEmpty else {
                return
            }
            sendTypingIndicator()
        }
    }

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatch: @escaping ActionDispatch) {
        self.logger = logger
        self.dispatch = dispatch

        sendButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .send,
            buttonType: .sendButton,
            isDisabled: true) { [weak self] in
                guard let self = self else {
                    return
                }
                self.sendMessage()
        }
        
        attachmentButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .attachmentIcon,
            isDisabled: false,
            action: {
                self.uploadAttachment()
            }
        )
//        sendButtonViewModel.update(
//            accessibilityLabel: self.localizationProvider.getLocalizedString(.sendAccessibilityLabel))
    }
    
    func uploadAttachment() {
        print("uploadAttachment")
        self.showFilePicker = true
        self.showFilePicker.toggle()
    }

    func sendMessage() {
        let fileUrl = BottomBarView.UploadedFileUrl
        guard let isFileEmpty:Bool = fileUrl?.isEmpty else {return}
    
        var metadataSet: [String: String?]? = [:]
        metadataSet?.updateValue("\(!isFileEmpty)", forKey: "hasAttachment")
        metadataSet?.updateValue(fileUrl, forKey: "attachmentUrl")
        dispatch(.repositoryAction(.sendMessageTriggered(
            internalId: UUID().uuidString,
            content: message.trim(),
            metadata: metadataSet)))
        message = ""
        BottomBarView.UploadedFileUrl = ""
    }

    func sendTypingIndicator() {
        if lastTypingIndicatorSendTimestamp < Date() - typingIndicatorDelay {
            dispatch(.chatAction(.sendTypingIndicatorTriggered))
            lastTypingIndicatorSendTimestamp = Date()
        }
    }

    func update(chatState: ChatState) {
        guard isLocalUserRemoved != chatState.isLocalUserRemovedFromChat else {
            return
        }
        isLocalUserRemoved = chatState.isLocalUserRemovedFromChat
    }
}
