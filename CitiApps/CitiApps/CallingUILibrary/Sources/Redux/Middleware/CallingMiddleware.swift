//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Middleware {
    static func liveCallingMiddleware(callingMiddlewareHandler actionHandler: CallingMiddlewareHandling, isVideoCall : Bool = false)
    -> Middleware<AppState> {
        Middleware<AppState>(
            apply: { dispatch, getState in
                return { next in
                    return { action in
                        switch action {
                        case .callingAction(let callingAction):
                            handleCallingAction(callingAction, actionHandler, getState,isVideoCall: isVideoCall, dispatch)

                        case .localUserAction(let localUserAction):
                            handleLocalUserAction(localUserAction, actionHandler, getState, dispatch)

                        case .permissionAction(let permissionAction):
                            handlePermissionAction(permissionAction, actionHandler, getState, dispatch)

                        case .lifecycleAction(let lifecycleAction):
                            handleLifecycleAction(lifecycleAction, actionHandler, getState, dispatch)

                        case .audioSessionAction(let audioAction):
                            handleAudioSessionAction(audioAction, actionHandler, getState, dispatch)

                        case .errorAction(_),
                                .callingViewLaunched:
                            break
                        case .compositeExitAction:
//                            print("compositeExitAction")
//                            let action: LocalUserAction = .cameraOffTriggered
//                            dispatch(.localUserAction(action))
                            actionHandler.autoDimissCall(state: getState(), dispatch: dispatch)
                        case .startScreenShareAction(let screenShareAction):
                            handleLocalUserAction(screenShareAction, actionHandler, getState, dispatch)

                        case .stopScreenShareAction(let screenShareAction):
                            handleLocalUserAction(screenShareAction, actionHandler, getState, dispatch)
                        }
                        return next(action)
                    }
                }
            }
        )
    }
}

private func handleCallingAction(_ action: CallingAction,
                                 _ actionHandler: CallingMiddlewareHandling,
                                 _ getState: () -> AppState, isVideoCall : Bool = false,
                                 _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .setupCall:
        actionHandler.setupCall(state: getState(),isVideoCall: isVideoCall, dispatch: dispatch)
    case .callStartRequested:
        actionHandler.startCall(state: getState(), dispatch: dispatch)
    case .callEndRequested:
        actionHandler.endCall(state: getState(), dispatch: dispatch)
    case .holdRequested:
        actionHandler.holdCall(state: getState(), dispatch: dispatch)
    case .resumeRequested:
        actionHandler.resumeCall(state: getState(), dispatch: dispatch)
    default:
        break
    }
}

private func handleLocalUserAction(_ action: LocalUserAction,
                                   _ actionHandler: CallingMiddlewareHandling,
                                   _ getState: () -> AppState,
                                   _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .cameraPreviewOnTriggered:
        actionHandler.requestCameraPreviewOn(state: getState(), dispatch: dispatch)
    case .cameraOnTriggered:
        actionHandler.requestCameraOn(state: getState(), dispatch: dispatch)
    case .cameraOffTriggered:
        actionHandler.requestCameraOff(state: getState(), dispatch: dispatch)
    case .cameraSwitchTriggered:
        actionHandler.requestCameraSwitch(state: getState(), dispatch: dispatch)
    case .microphoneOffTriggered:
        actionHandler.requestMicrophoneMute(state: getState(), dispatch: dispatch)
    case .microphoneOnTriggered:
        actionHandler.requestMicrophoneUnmute(state: getState(), dispatch: dispatch)

    case .cameraOnSucceeded(videoStreamIdentifier: _),
            .cameraOnFailed(error: _),
            .cameraOffSucceeded,
            .cameraOffFailed(error: _),
            .cameraPausedSucceeded,
            .cameraPausedFailed(error: _),
            .cameraSwitchSucceeded(cameraDevice: _),
            .cameraSwitchFailed(error: _),
            .microphoneOnFailed(error: _),
            .microphoneOffFailed(error: _),
            .microphoneMuteStateUpdated(isMuted: _),
            .microphonePreviewOn,
            .microphonePreviewOff,
            .audioDeviceChangeRequested(device: _),
            .audioDeviceChangeSucceeded(device: _),
            .audioDeviceChangeFailed(error: _):
        break
    case .screenSharingOffTriggered:
        actionHandler.stopScreenSharing(state: getState(), dispatch: dispatch)

    case .screenSharingOnTriggered:
        actionHandler.startScreenSharing(state: getState(), dispatch: dispatch)

    }
}

private func handlePermissionAction(_ action: PermissionAction,
                                    _ actionHandler: CallingMiddlewareHandling,
                                    _ getState: () -> AppState,
                                    _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .cameraPermissionGranted:
        actionHandler.onCameraPermissionIsSet(state: getState(), dispatch: dispatch)

    case .audioPermissionRequested,
            .audioPermissionGranted,
            .audioPermissionDenied,
            .audioPermissionNotAsked,
            .cameraPermissionRequested,
            .cameraPermissionDenied,
            .cameraPermissionNotAsked:
        break
    }
}

private func handleLifecycleAction(_ action: LifecycleAction,
                                   _ actionHandler: CallingMiddlewareHandling,
                                   _ getState: () -> AppState,
                                   _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .backgroundEntered:
        actionHandler.enterBackground(state: getState(), dispatch: dispatch)
    case .foregroundEntered:
        actionHandler.enterForeground(state: getState(), dispatch: dispatch)
    case .willTerminate:
        if getState().callingState.status == .connected {
            actionHandler.endCall(state: getState(), dispatch: dispatch)
        }
    }
}

private func handleAudioSessionAction(_ action: AudioSessionAction,
                                      _ actionHandler: CallingMiddlewareHandling,
                                      _ getState: () -> AppState,
                                      _ dispatch: @escaping ActionDispatch) {
    switch action {
    case .audioInterrupted:
        actionHandler.audioSessionInterrupted(state: getState(), dispatch: dispatch)
    case .audioInterruptEnded,
            .audioEngaged:
        break
    }
}
