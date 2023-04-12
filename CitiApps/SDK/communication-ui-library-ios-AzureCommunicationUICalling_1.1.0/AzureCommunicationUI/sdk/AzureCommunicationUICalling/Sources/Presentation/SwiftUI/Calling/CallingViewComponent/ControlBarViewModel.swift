//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine


class ControlBarViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch
    private var isCameraStateUpdating: Bool = false
    private(set) var cameraButtonViewModel: IconButtonViewModel!

    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var isAudioDeviceSelectionDisplayed: Bool = false
    @Published var isConfirmLeaveListDisplayed: Bool = false
    
    var chatActive: Bool = false
    
    var teamsMeetingLink: String = ""


    let audioDevicesListViewModel: AudioDevicesListViewModel

    var chatButtonViewModel: IconButtonViewModel!
    var micButtonViewModel: IconButtonViewModel!
    var screenShareButtonViewModel: IconButtonViewModel!
    var audioDeviceButtonViewModel: IconButtonViewModel!
    var hangUpButtonViewModel: IconButtonViewModel!
    var callingStatus: CallingStatus = .none
    var cameraState = LocalUserState.CameraState(operation: .off,
                                                 device: .front,
                                                 transmission: .local)
    var audioState = LocalUserState.AudioState(operation: .off,
                                               device: .receiverSelected)
    
    var screenShareState = LocalUserState.ScreenShareState(screen: .sharingOff)
    var displayEndCallConfirm: (() -> Void)

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         endCallConfirm: @escaping (() -> Void),
         localUserState: LocalUserState,
         teamsMeetingLink: String) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.displayEndCallConfirm = endCallConfirm
        self.teamsMeetingLink = teamsMeetingLink

        audioDevicesListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
            dispatchAction: dispatch,
            localUserState: localUserState)

        cameraButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .videoOff,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle camera button tapped")
                self.cameraButtonTapped()
        }
        cameraButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .videoOffAccessibilityLabel)
        
        chatButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .chat,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Chat button tapped")
                self.chatButtonTapped()
        }

        micButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .micOff,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle microphone button tapped")
                self.microphoneButtonTapped()
        }
        
        screenShareButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .share_screen_icon,
            buttonType: .controlButton,
            isDisabled: false,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.screenShareButtonTapped()
            }
        )
        micButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .micOffAccessibilityLabel)

        audioDeviceButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .speakerFilled,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Select audio device button tapped")
                self.selectAudioDeviceButtonTapped()
        }
        audioDeviceButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .deviceAccesibiiltyLabel)

        hangUpButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .endCall,
            buttonType: .roundedRectButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Hangup button tapped")
                self.endCallButtonTapped()
        }
        hangUpButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .leaveCall)
    }
    
    func chatButtonTapped () {
        
    }

    func endCallButtonTapped() {
        self.isConfirmLeaveListDisplayed = true
    }

    func cameraButtonTapped() {
        guard !isCameraStateUpdating else {
            return
        }
        print("cameraButtonTapped :\(cameraState.operation)")
//        isCameraStateUpdating = true
        let action: LocalUserAction = cameraState.operation == .on ?
            .cameraOffTriggered : .cameraOnTriggered
        dispatch(.localUserAction(action))
    }

    func microphoneButtonTapped() {
        let action: LocalUserAction = audioState.operation == .on ?
        .microphoneOffTriggered : .microphoneOnTriggered
        dispatch(.localUserAction(action))
    }
    
    func screenShareButtonTapped() {
        let action: LocalUserAction = screenShareState.screen == .sharingOff ? .screenSharingOnTriggered : .screenSharingOffTriggered
        dispatch(.localUserAction(action))
    }

    func selectAudioDeviceButtonTapped() {
        self.isAudioDeviceSelectionDisplayed = true
    }

    func dismissConfirmLeaveDrawerList() {
        self.isConfirmLeaveListDisplayed = false
    }

    func isCameraDisabled() -> Bool {
        cameraPermission == .denied || cameraState.operation == .pending ||
        callingStatus == .localHold || isCameraStateUpdating
    }

    func isMicDisabled() -> Bool {
        audioState.operation == .pending || callingStatus == .localHold
    }
    
    func isScreenShare() -> Bool {
        screenShareState.screen == .sharingOn
    }

    func isAudioDeviceDisabled() -> Bool {
        callingStatus == .localHold
    }

    func getLeaveCallButtonViewModel() -> LeaveCallConfirmationViewModel {
        return LeaveCallConfirmationViewModel(
            icon: .endCallRegular,
            title: localizationProvider.getLocalizedString(.leaveCall),
            accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Leave call button tapped")
                self.displayEndCallConfirm()
            })
    }

    func getCancelButtonViewModel() -> LeaveCallConfirmationViewModel {
        return LeaveCallConfirmationViewModel(
            icon: .dismiss,
            title: localizationProvider.getLocalizedString(.cancel),
            accessibilityIdentifier: AccessibilityIdentifier.cancelAccessibilityID.rawValue,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Cancel button tapped")
                self.dismissConfirmLeaveDrawerList()
            })
    }

    func getLeaveCallConfirmationListViewModel() -> LeaveCallConfirmationListViewModel {
        let leaveCallConfirmationVm: [LeaveCallConfirmationViewModel] = [
            getLeaveCallButtonViewModel(),
            getCancelButtonViewModel()
        ]
        let headerName = localizationProvider.getLocalizedString(.leaveCallListHeader)
        return LeaveCallConfirmationListViewModel(headerName: headerName,
                                                  listItemViewModel: leaveCallConfirmationVm)
    }

    func update(localUserState: LocalUserState,
                permissionState: PermissionState,
                callingState: CallingState) {
        callingStatus = callingState.status
        if cameraPermission != permissionState.cameraPermission {
            cameraPermission = permissionState.cameraPermission
        }

        if isCameraStateUpdating,
           cameraState.operation != localUserState.cameraState.operation {
            isCameraStateUpdating = localUserState.cameraState.operation != .on &&
                                    localUserState.cameraState.operation != .off
        }
        cameraState = localUserState.cameraState
        cameraButtonViewModel.update(iconName: cameraState.operation == .on ? .videoOn : .videoOff)
        cameraButtonViewModel.update(accessibilityLabel: cameraState.operation == .on
                                     ? localizationProvider.getLocalizedString(.videoOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.videoOffAccessibilityLabel))
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())

        audioState = localUserState.audioState
        micButtonViewModel.update(iconName: audioState.operation == .on ? .micOn : .micOff)
        micButtonViewModel.update(accessibilityLabel: audioState.operation == .on
                                     ? localizationProvider.getLocalizedString(.micOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.micOffAccessibilityLabel))
        micButtonViewModel.update(isDisabled: isMicDisabled())
        
        screenShareState = localUserState.screenShareState
        screenShareButtonViewModel.update(iconName: screenShareState.screen == .sharingOn ? .stop_screen_share_icon : .share_screen_icon)
        audioDeviceButtonViewModel.update(isDisabled: isAudioDeviceDisabled())
        let audioDeviceState = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            iconName: audioDeviceState.icon
        )
        audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceState.getLabel(localizationProvider: localizationProvider))
        audioDevicesListViewModel.update(audioDeviceStatus: audioDeviceState)
    }
}
