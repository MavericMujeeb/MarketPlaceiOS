// ACSCallingShared
// This file was auto-generated from ACSCallingModelBETA.cs.

#import <Foundation/Foundation.h>

#import <CoreVideo/CoreVideo.h>
#import <AzureCommunicationCommon/AzureCommunicationCommon-Swift.h>
#import "ACSCallKit.h"
#import "ACSVideoStreamRenderer.h"
#import "ACSVideoStreamRendererView.h"
#import "ACSStreamSize.h"
#import "ACSFeatures.h"

// Enumerations.
/// Additional failed states for Azure Communication Services
typedef NS_OPTIONS(NSInteger, ACSCallingCommunicationErrors)
{
    /// No errors
    ACSCallingCommunicationErrorsNone = 0,
    /// No Audio permissions available.
    ACSCallingCommunicationErrorsNoAudioPermission = 1,
    /// No Video permissions available.
    ACSCallingCommunicationErrorsNoVideoPermission = 2,
    /// No Video and Audio permissions available.
    ACSCallingCommunicationErrorsNoAudioAndVideoPermission = 3,
    /// Failed to process push notification payload.
    ACSCallingCommunicationErrorsReceivedInvalidPushNotificationPayload = 4,
    /// Received empty/invalid notification payload.
    ACSCallingCommunicationErrorsFailedToProcessPushNotificationPayload = 8,
    /// Received invalid group Id.
    ACSCallingCommunicationErrorsInvalidGuidGroupId = 16,
    /// Push notification device registration token is invalid.
    ACSCallingCommunicationErrorsInvalidPushNotificationDeviceRegistrationToken = 32,
    /// Cannot create multiple renders for same device or stream.
    ACSCallingCommunicationErrorsMultipleRenderersNotSupported = 64,
    /// Renderer doesn't support creating multiple views.
    ACSCallingCommunicationErrorsMultipleViewsNotSupported = 128,
    /// The local video stream on the video options is invalid.
    ACSCallingCommunicationErrorsInvalidLocalVideoStreamForVideoOptions = 256,
    /// No multiple connections with same identity per app is allowed.
    ACSCallingCommunicationErrorsNoMultipleConnectionsWithSameIdentity = 512,
    /// Invalid server call Id because it's empty or has invalid values.
    ACSCallingCommunicationErrorsInvalidServerCallId = 1024,
    /// Failure while switch source on a local video stream.
    ACSCallingCommunicationErrorsLocalVideoStreamSwitchSourceFailure = 2048,
    /// Attempt to answer an incoming call that has been unplaced.
    ACSCallingCommunicationErrorsIncomingCallAlreadyUnplaced = 4096,
    /// Invalid meeting link provided.
    ACSCallingCommunicationErrorsInvalidMeetingLink = 16384,
    /// Attempt to add participant to a unconnected call.
    ACSCallingCommunicationErrorsParticipantAddedToUnconnectedCall = 32768,
    /// Participant already added to the call.
    ACSCallingCommunicationErrorsParticipantAlreadyAddedToCall = 65536,
    /// Call feature extension not found.
    ACSCallingCommunicationErrorsCallFeatureExtensionNotFound = 131072,
    /// Virtual tried to register an already registered device id.
    ACSCallingCommunicationErrorsDuplicateDeviceId = 262144,
    /// App is expected to register a delegation to complete the operation.
    ACSCallingCommunicationErrorsDelegateIsRequired = 524288,
    /// Virtual device is not started.
    ACSCallingCommunicationErrorsVirtualDeviceNotStarted = 1048576,
    /// Invalid video stream combination provided.
    ACSCallingCommunicationErrorsInvalidVideoStreamCombination = 4194304,
    /// User display name is longer than the supported length.
    ACSCallingCommunicationErrorsDisplayNameLengthLongerThanSupported = 8388608,
    /// Cannot hangup for everyone in a non-hostless call
    ACSCallingCommunicationErrorsFailedToHangupForEveryone = 16777216,
    /// No multiple connections with different cloud type per app is allowed.
    ACSCallingCommunicationErrorsNoMultipleConnectionsWithDifferentClouds = 33554432,
    /// No active audio stream to stop.
    ACSCallingCommunicationErrorsNoActiveAudioStreamToStop = 67108864,
    /// Start teams captions failed
    ACSCallingCommunicationErrorsTeamsCaptionsCallFeatureStartFailed = 536870912,
    /// Teams Captions set spoken language failed
    ACSCallingCommunicationErrorsTeamsCaptionsCallFeatureSetSpokenLanguageFailed = 8192,
    /// Teams Captions set caption language failed
    ACSCallingCommunicationErrorsTeamsCaptionsCallFeatureSetCaptionLanguageFailed = 2097152,
    /// Feature extension not found.
    ACSCallingCommunicationErrorsFeatureExtensionNotFound = 134217728,
    /// Video effect not supported by device
    ACSCallingCommunicationErrorsVideoEffectNotSupported = 268435456
} NS_SWIFT_NAME(CallingCommunicationErrors);

/// Local and Remote Video Stream types
typedef NS_ENUM(NSInteger, ACSMediaStreamType)
{
    /// Video
    ACSMediaStreamTypeVideo = 1,
    /// Screen share
    ACSMediaStreamTypeScreenSharing = 2
} NS_SWIFT_NAME(MediaStreamType);

/// Type of outgoing video stream is being used on the call
typedef NS_ENUM(NSInteger, ACSOutgoingVideoStreamKind)
{
    /// None
    ACSOutgoingVideoStreamKindNone = 0,
    /// Local
    ACSOutgoingVideoStreamKindLocal = 1,
    /// Video
    ACSOutgoingVideoStreamKindVirtual = 2,
    /// Screen share
    ACSOutgoingVideoStreamKindScreenShare = 3
} NS_SWIFT_NAME(OutgoingVideoStreamKind);

/// Defines possible running states for a virtual device.
typedef NS_ENUM(NSInteger, ACSOutgoingVideoStreamState)
{
    /// None
    ACSOutgoingVideoStreamStateNone = 0,
    /// Started
    ACSOutgoingVideoStreamStateStarted = 1,
    /// Stopped
    ACSOutgoingVideoStreamStateStopped = 2,
    /// Failed
    ACSOutgoingVideoStreamStateFailed = 3
} NS_SWIFT_NAME(OutgoingVideoStreamState);

/// Direction of the camera
typedef NS_ENUM(NSInteger, ACSCameraFacing)
{
    /// Unknown
    ACSCameraFacingUnknown = 0,
    /// External device
    ACSCameraFacingExternal = 1,
    /// Front camera
    ACSCameraFacingFront = 2,
    /// Back camera
    ACSCameraFacingBack = 3,
    /// Panoramic camera
    ACSCameraFacingPanoramic = 4,
    /// Left front camera
    ACSCameraFacingLeftFront = 5,
    /// Right front camera
    ACSCameraFacingRightFront = 6
} NS_SWIFT_NAME(CameraFacing);

/// Describes the video device type
typedef NS_ENUM(NSInteger, ACSVideoDeviceType)
{
    /// Unknown type of video device
    ACSVideoDeviceTypeUnknown = 0,
    /// USB Camera Video Device
    ACSVideoDeviceTypeUsbCamera = 1,
    /// Capture Adapter Video Device
    ACSVideoDeviceTypeCaptureAdapter = 2,
    /// Virtual Video Device
    ACSVideoDeviceTypeVirtual = 3
} NS_SWIFT_NAME(VideoDeviceType);

/// Type of outgoing audio stream is being used on the call
typedef NS_ENUM(NSInteger, ACSAudioStreamKind)
{
    /// None
    ACSAudioStreamKindNone = 0,
    /// Local
    ACSAudioStreamKindLocal = 1,
    /// Audio
    ACSAudioStreamKindVirtual = 2
} NS_SWIFT_NAME(AudioStreamKind);

typedef NS_ENUM(NSInteger, ACSPushNotificationEventType)
{
    ACSPushNotificationEventTypeNone = 0,
    ACSPushNotificationEventTypeIncomingCall = 107,
    ACSPushNotificationEventTypeIncomingGroupCall = 109,
    ACSPushNotificationEventTypeIncomingPstnCall = 111,
    ACSPushNotificationEventTypeStopRinging = 110
} NS_SWIFT_NAME(PushNotificationEventType);

typedef NS_ENUM(NSInteger, ACSParticipantRole)
{
    /// Unknown
    ACSParticipantRoleUnknown = 0,
    /// Attendee
    ACSParticipantRoleAttendee = 1,
    /// Consumer
    ACSParticipantRoleConsumer = 2,
    /// Presenter
    ACSParticipantRolePresenter = 3,
    /// Organizer
    ACSParticipantRoleOrganizer = 4
} NS_SWIFT_NAME(ParticipantRole);

/// State of a participant in the call
typedef NS_ENUM(NSInteger, ACSParticipantState)
{
    /// Idle
    ACSParticipantStateIdle = 0,
    /// Early Media
    ACSParticipantStateEarlyMedia = 1,
    /// Connecting
    ACSParticipantStateConnecting = 2,
    /// Connected
    ACSParticipantStateConnected = 3,
    /// On Hold
    ACSParticipantStateHold = 4,
    /// In Lobby
    ACSParticipantStateInLobby = 5,
    /// Disconnected
    ACSParticipantStateDisconnected = 6,
    /// Ringing
    ACSParticipantStateRinging = 7
} NS_SWIFT_NAME(ParticipantState);

/// State of a call
typedef NS_ENUM(NSInteger, ACSCallState)
{
    /// None - disposed or applicable very early in lifetime of a call
    ACSCallStateNone = 0,
    /// Early Media
    ACSCallStateEarlyMedia = 1,
    /// Call is being connected
    ACSCallStateConnecting = 3,
    /// Call is ringing
    ACSCallStateRinging = 4,
    /// Call is connected
    ACSCallStateConnected = 5,
    /// Call held by local participant
    ACSCallStateLocalHold = 6,
    /// Call is being disconnected
    ACSCallStateDisconnecting = 7,
    /// Call is disconnected
    ACSCallStateDisconnected = 8,
    /// In Lobby
    ACSCallStateInLobby = 9,
    /// Call held by a remote participant
    ACSCallStateRemoteHold = 10
} NS_SWIFT_NAME(CallState);

/// Direction of a Call
typedef NS_ENUM(NSInteger, ACSCallDirection)
{
    /// Outgoing call
    ACSCallDirectionOutgoing = 1,
    /// Incoming call
    ACSCallDirectionIncoming = 2
} NS_SWIFT_NAME(CallDirection);

/// Defines direction of the AudioStream or VideoStream
typedef NS_ENUM(NSInteger, ACSMediaStreamDirection)
{
    /// None
    ACSMediaStreamDirectionNone = 0,
    /// Incoming
    ACSMediaStreamDirectionIncoming = 1,
    /// Outgoing
    ACSMediaStreamDirectionOutgoing = 2
} NS_SWIFT_NAME(MediaStreamDirection);

/// DTMF (Dual-Tone Multi-Frequency) tone for PSTN calls
typedef NS_ENUM(NSInteger, ACSDtmfTone)
{
    /// Zero
    ACSDtmfToneZero = 0,
    /// One
    ACSDtmfToneOne = 1,
    /// Two
    ACSDtmfToneTwo = 2,
    /// Three
    ACSDtmfToneThree = 3,
    /// Four
    ACSDtmfToneFour = 4,
    /// Five
    ACSDtmfToneFive = 5,
    /// Six
    ACSDtmfToneSix = 6,
    /// Seven
    ACSDtmfToneSeven = 7,
    /// Eight
    ACSDtmfToneEight = 8,
    /// Nine
    ACSDtmfToneNine = 9,
    /// Star
    ACSDtmfToneStar = 10,
    /// Pound
    ACSDtmfTonePound = 11,
    /// A
    ACSDtmfToneA = 12,
    /// B
    ACSDtmfToneB = 13,
    /// C
    ACSDtmfToneC = 14,
    /// D
    ACSDtmfToneD = 15,
    /// Flash
    ACSDtmfToneFlash = 16
} NS_SWIFT_NAME(DtmfTone);

/// Local and Remote Video scaling mode
typedef NS_ENUM(NSInteger, ACSScalingMode)
{
    /// Cropped
    ACSScalingModeCrop = 1,
    /// Fitted
    ACSScalingModeFit = 2
} NS_SWIFT_NAME(ScalingMode);

/// Indicates the state of recording
typedef NS_ENUM(NSInteger, ACSRecordingState)
{
    /// Recording started
    ACSRecordingStateStarted = 0,
    /// Recording paused
    ACSRecordingStatePaused = 1,
    /// Recording stopped
    ACSRecordingStateEnded = 2
} NS_SWIFT_NAME(RecordingState);

typedef NS_ENUM(NSInteger, ACSCaptionsResultType)
{
    /// Text contains partially spoken sentence.
    ACSCaptionsResultTypePartial = 0,
    /// Sentence has been completely transcribed.
    ACSCaptionsResultTypeFinal = 1
} NS_SWIFT_NAME(CaptionsResultType);

/// Informs how media frames will be available for encoding or decoding.
typedef NS_ENUM(NSInteger, ACSVideoFrameKind)
{
    /// No media frame type defined. This is the default.
    ACSVideoFrameKindNone = 0,
    /// VideoSoftware allows video frames content available in RAM to be encoded and decoded using CPU resources. In order to allow fall backs on GPU failures, at least one VideoFormat should be of the VideoFrameKind::VideoSoftware type.
    ACSVideoFrameKindVideoSoftware = 1,
    /// VideoHardware allows video frames content available via platform specific hardware accelerated format. For instance, IMFSample on Windows and GL textures on Android.
    ACSVideoFrameKindVideoHardware = 2
} NS_SWIFT_NAME(VideoFrameKind);

/// Informs how the pixels of the video frame is encoded.
typedef NS_ENUM(NSInteger, ACSPixelFormat)
{
    /// No pixel format defined. This is the default.
    ACSPixelFormatNone = 0,
    /// Pixel format is encoded as single plane with 32 bits per pixels, 8 bits per channel, ordered as blue, followed by green, followed by red and discarding the last 8 bits.
    ACSPixelFormatBgrx = 1,
    /// Pixel format is encoded as single plane with 24 bits per pixels, 8 bits per channel, ordered as blue, followed by green, followed by red.
    ACSPixelFormatBgr24 = 2,
    /// Pixel format is encoded as single plane with 32 bits per pixels, 8 bits per channel, ordered as blue, followed by green, followed by red and discarding the last 8 bits.
    ACSPixelFormatRgbx = 3,
    /// Pixel format is encoded as single plane with 32 bits per pixels, 8 bits per channel, ordered as blue, followed by green, followed by red and alpha as 8 bits each. Alpha is discarded.
    ACSPixelFormatRgba = 4,
    /// Pixel format  is encoded as YUV 4:2:0 with a plane of 8 bit Y samples, followed by an interleaved U/V plane containing 8 bit 2x2 sub-sampled color difference samples.
    ACSPixelFormatNv12 = 5,
    /// Pixel format is encoded as YUV 4:2:0 with a plane of 8 bit ordered by Y, followed by a U plane, followed by a V plane.
    ACSPixelFormatI420 NS_SWIFT_NAME(i420) = 6
} NS_SWIFT_NAME(PixelFormat);

typedef NS_ENUM(NSInteger, ACSResultType)
{
    /// Text contains partially spoken sentence.
    ACSResultTypeIntermediate = 0,
    /// Sentence has been completely transcribed.
    ACSResultTypeFinal = 1
} NS_SWIFT_NAME(ResultType);

/// Represents a diagnostic quality scale.
typedef NS_ENUM(NSInteger, ACSDiagnosticQuality)
{
    /// Unknown
    ACSDiagnosticQualityUnknown = 0,
    /// Good
    ACSDiagnosticQualityGood = 1,
    /// Poor
    ACSDiagnosticQualityPoor = 2,
    /// Bad
    ACSDiagnosticQualityBad = 3
} NS_SWIFT_NAME(DiagnosticQuality);

// MARK: Forward declarations.
@class ACSOutgoingVideoStream;
@class ACSVideoOptions;
@class ACSLocalVideoStream;
@class ACSVideoDeviceInfo;
@class ACSOutgoingVideoStreamStateChangedEventArgs;
@class ACSAudioOptions;
@class ACSAudioStream;
@class ACSIncomingAudioStream;
@class ACSOutgoingAudioStream;
@class ACSJoinCallOptions;
@class ACSAcceptCallOptions;
@class ACSStartCallOptions;
@class ACSAddPhoneNumberOptions;
@class ACSJoinMeetingLocator;
@class ACSGroupCallLocator;
@class ACSTeamsMeetingCoordinatesLocator;
@class ACSTeamsMeetingLinkLocator;
@class ACSCallerInfo;
@class ACSPushNotificationInfo;
@class ACSCallAgentOptions;
@class ACSEmergencyCallOptions;
@class ACSCallAgent;
@class ACSCall;
@class ACSRemoteParticipant;
@class ACSCallEndReason;
@class ACSRemoteVideoStream;
@class ACSPropertyChangedEventArgs;
@class ACSRemoteVideoStreamsEventArgs;
@class ACSCallInfo;
@class ACSParticipantsUpdatedEventArgs;
@class ACSLocalVideoStreamsUpdatedEventArgs;
@class ACSHangUpOptions;
@class ACSCallFeature;
@class ACSCallsUpdatedEventArgs;
@class ACSIncomingCall;
@class ACSCallClient;
@class ACSCallClientOptions;
@class ACSCallDiagnosticsOptions;
@class ACSDeviceManager;
@class ACSVideoDevicesUpdatedEventArgs;
@class ACSRecordingUpdatedEventArgs;
@class ACSRecordingInfo;
@class ACSRecordingCallFeature;
@class ACSTranscriptionCallFeature;
@class ACSTeamsCaptionsCallFeature;
@class ACSStartCaptionsOptions;
@class ACSTeamsCaptionsInfo;
@class ACSDominantSpeakersCallFeature;
@class ACSDominantSpeakersInfo;
@class ACSRaiseHandCallFeature;
@class ACSRaisedHand;
@class ACSRaisedHandChangedEventArgs;
@class ACSCreateViewOptions;
@class ACSVideoFormat;
@class ACSVideoFrameSenderChangedEventArgs;
@class ACSVideoFrameSender;
@class ACSRawOutgoingVideoStreamOptions;
@class ACSFrameConfirmation;
@class ACSSoftwareBasedVideoFrameSender;
@class ACSRawOutgoingVideoStream;
@class ACSScreenShareRawOutgoingVideoStream;
@class ACSVirtualRawOutgoingVideoStream;
@class ACSRoomCallLocator;
@class ACSLocalAudioStream;
@class ACSRemoteAudioStream;
@class ACSDiagnosticsCallFeature;
@class ACSNetworkDiagnostics;
@class ACSNetworkDiagnosticValues;
@class ACSFlagDiagnosticChangedEventArgs;
@class ACSQualityDiagnosticChangedEventArgs;
@class ACSMediaDiagnostics;
@class ACSMediaDiagnosticValues;
@protocol ACSLocalVideoStreamDelegate;
@class ACSLocalVideoStreamEvents;
@protocol ACSCallAgentDelegate;
@class ACSCallAgentEvents;
@protocol ACSCallDelegate;
@class ACSCallEvents;
@protocol ACSRemoteParticipantDelegate;
@class ACSRemoteParticipantEvents;
@protocol ACSIncomingCallDelegate;
@class ACSIncomingCallEvents;
@protocol ACSDeviceManagerDelegate;
@class ACSDeviceManagerEvents;
@protocol ACSRecordingCallFeatureDelegate;
@class ACSRecordingCallFeatureEvents;
@protocol ACSTranscriptionCallFeatureDelegate;
@class ACSTranscriptionCallFeatureEvents;
@protocol ACSTeamsCaptionsCallFeatureDelegate;
@class ACSTeamsCaptionsCallFeatureEvents;
@protocol ACSDominantSpeakersCallFeatureDelegate;
@class ACSDominantSpeakersCallFeatureEvents;
@protocol ACSRaiseHandCallFeatureDelegate;
@class ACSRaiseHandCallFeatureEvents;
@protocol ACSRawOutgoingVideoStreamOptionsDelegate;
@class ACSRawOutgoingVideoStreamOptionsEvents;
@protocol ACSScreenShareRawOutgoingVideoStreamDelegate;
@class ACSScreenShareRawOutgoingVideoStreamEvents;
@protocol ACSVirtualRawOutgoingVideoStreamDelegate;
@class ACSVirtualRawOutgoingVideoStreamEvents;
@protocol ACSNetworkDiagnosticsDelegate;
@class ACSNetworkDiagnosticsEvents;
@protocol ACSMediaDiagnosticsDelegate;
@class ACSMediaDiagnosticsEvents;

NS_SWIFT_NAME(LocalVideoStreamEvents)
@interface ACSLocalVideoStreamEvents : NSObject
@property (copy, nullable) void (^onOutgoingVideoStreamStateChanged)(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(CallAgentEvents)
@interface ACSCallAgentEvents : NSObject
@property (copy, nullable) void (^onCallsUpdated)(ACSCallsUpdatedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIncomingCall)(ACSIncomingCall * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(CallEvents)
@interface ACSCallEvents : NSObject
@property (copy, nullable) void (^onIdChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onStateChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onRoleChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onRemoteParticipantsUpdated)(ACSParticipantsUpdatedEventArgs * _Nonnull);
@property (copy, nullable) void (^onLocalVideoStreamsUpdated)(ACSLocalVideoStreamsUpdatedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIsMutedChanged)(ACSPropertyChangedEventArgs * _Nonnull) DEPRECATED_MSG_ATTRIBUTE("Deprecated use OnIsOutgoingAudioStateChanged instead");
@property (copy, nullable) void (^onIsOutgoingAudioStateChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onTotalParticipantCountChanged)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(RemoteParticipantEvents)
@interface ACSRemoteParticipantEvents : NSObject
@property (copy, nullable) void (^onStateChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIsMutedChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIsSpeakingChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onDisplayNameChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onRoleChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onVideoStreamsUpdated)(ACSRemoteVideoStreamsEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(IncomingCallEvents)
@interface ACSIncomingCallEvents : NSObject
@property (copy, nullable) void (^onCallEnded)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(DeviceManagerEvents)
@interface ACSDeviceManagerEvents : NSObject
@property (copy, nullable) void (^onCamerasUpdated)(ACSVideoDevicesUpdatedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(RecordingCallFeatureEvents)
@interface ACSRecordingCallFeatureEvents : NSObject
@property (copy, nullable) void (^onIsRecordingActiveChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onRecordingUpdated)(ACSRecordingUpdatedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(TranscriptionCallFeatureEvents)
@interface ACSTranscriptionCallFeatureEvents : NSObject
@property (copy, nullable) void (^onIsTranscriptionActiveChanged)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(TeamsCaptionsCallFeatureEvents)
@interface ACSTeamsCaptionsCallFeatureEvents : NSObject
@property (copy, nullable) void (^onCaptionsActiveChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onCaptionsReceived)(ACSTeamsCaptionsInfo * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(DominantSpeakersCallFeatureEvents)
@interface ACSDominantSpeakersCallFeatureEvents : NSObject
@property (copy, nullable) void (^onDominantSpeakersChanged)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(RaiseHandCallFeatureEvents)
@interface ACSRaiseHandCallFeatureEvents : NSObject
@property (copy, nullable) void (^onRaisedHandReceived)(ACSRaisedHandChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onLoweredHandReceived)(ACSRaisedHandChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(RawOutgoingVideoStreamOptionsEvents)
@interface ACSRawOutgoingVideoStreamOptionsEvents : NSObject
@property (copy, nullable) void (^onVideoFrameSenderChanged)(ACSVideoFrameSenderChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onOutgoingVideoStreamStateChanged)(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(ScreenShareRawOutgoingVideoStreamEvents)
@interface ACSScreenShareRawOutgoingVideoStreamEvents : NSObject
@property (copy, nullable) void (^onOutgoingVideoStreamStateChanged)(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(VirtualRawOutgoingVideoStreamEvents)
@interface ACSVirtualRawOutgoingVideoStreamEvents : NSObject
@property (copy, nullable) void (^onOutgoingVideoStreamStateChanged)(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(NetworkDiagnosticsEvents)
@interface ACSNetworkDiagnosticsEvents : NSObject
@property (copy, nullable) void (^onNoNetworkChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onNetworkRelaysNotReachableChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onNetworkReconnectChanged)(ACSQualityDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onNetworkReceiveQualityChanged)(ACSQualityDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onNetworkSendQualityChanged)(ACSQualityDiagnosticChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(MediaDiagnosticsEvents)
@interface ACSMediaDiagnosticsEvents : NSObject
@property (copy, nullable) void (^onSpeakerNotFunctioningChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onSpeakerNotFunctioningDeviceInUseChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onSpeakerMutedChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onSpeakerVolumeIsZeroChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onNoSpeakerDevicesEnumeratedChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onSpeakingWhileMicrophoneIsMutedChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onNoMicrophoneDevicesEnumeratedChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onMicrophoneNotFunctioningDeviceInUseChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onCameraFreezeChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onCameraStartFailedChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onCameraStartTimedOutChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onMicrophoneNotFunctioningChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onMicrophoneMuteUnexpectedlyChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onCameraPermissionDeniedChanged)(ACSFlagDiagnosticChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

/**
 * A set of methods that are called by ACSLocalVideoStream in response to important events.
 */
NS_SWIFT_NAME(LocalVideoStreamDelegate)
@protocol ACSLocalVideoStreamDelegate <NSObject>
@optional
- (void)onOutgoingVideoStreamStateChanged:(ACSLocalVideoStream * _Nonnull)localVideoStream :(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( localVideoStream(_:didChangeOutgoingVideoStreamState:));
@end

/**
 * A set of methods that are called by ACSCallAgent in response to important events.
 */
NS_SWIFT_NAME(CallAgentDelegate)
@protocol ACSCallAgentDelegate <NSObject>
@optional
- (void)onCallsUpdated:(ACSCallAgent * _Nonnull)callAgent :(ACSCallsUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( callAgent(_:didUpdateCalls:));
- (void)onIncomingCall:(ACSCallAgent * _Nonnull)callAgent :(ACSIncomingCall * _Nonnull)incomingCall NS_SWIFT_NAME( callAgent(_:didRecieveIncomingCall:));
@end

/**
 * A set of methods that are called by ACSCall in response to important events.
 */
NS_SWIFT_NAME(CallDelegate)
@protocol ACSCallDelegate <NSObject>
@optional
- (void)onIdChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeId:));
- (void)onStateChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeState:));
- (void)onRoleChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeRole:));
- (void)onRemoteParticipantsUpdated:(ACSCall * _Nonnull)call :(ACSParticipantsUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didUpdateRemoteParticipant:));
- (void)onLocalVideoStreamsUpdated:(ACSCall * _Nonnull)call :(ACSLocalVideoStreamsUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didUpdateLocalVideoStreams:));
- (void)onIsMutedChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeMuteState:)) DEPRECATED_MSG_ATTRIBUTE("Deprecated use call(_:didUpdateOutgoingAudioState:) instead");
- (void)onIsOutgoingAudioStateChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didUpdateOutgoingAudioState:));
- (void)onTotalParticipantCountChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeTotalParticipantCount:));
@end

/**
 * A set of methods that are called by ACSRemoteParticipant in response to important events.
 */
NS_SWIFT_NAME(RemoteParticipantDelegate)
@protocol ACSRemoteParticipantDelegate <NSObject>
@optional
- (void)onStateChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeState:));
- (void)onIsMutedChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeMuteState:));
- (void)onIsSpeakingChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeSpeakingState:));
- (void)onDisplayNameChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeDisplayName:));
- (void)onRoleChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeRole:));
- (void)onVideoStreamsUpdated:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSRemoteVideoStreamsEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didUpdateVideoStreams:));
@end

/**
 * A set of methods that are called by ACSIncomingCall in response to important events.
 */
NS_SWIFT_NAME(IncomingCallDelegate)
@protocol ACSIncomingCallDelegate <NSObject>
@optional
- (void)onCallEnded:(ACSIncomingCall * _Nonnull)incomingCall :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( incomingCall(_:didEnd:));
@end

/**
 * A set of methods that are called by ACSDeviceManager in response to important events.
 */
NS_SWIFT_NAME(DeviceManagerDelegate)
@protocol ACSDeviceManagerDelegate <NSObject>
@optional
- (void)onCamerasUpdated:(ACSDeviceManager * _Nonnull)deviceManager :(ACSVideoDevicesUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( deviceManager(_:didUpdateCameras:));
@end

/**
 * A set of methods that are called by ACSRecordingCallFeature in response to important events.
 */
NS_SWIFT_NAME(RecordingCallFeatureDelegate)
@protocol ACSRecordingCallFeatureDelegate <NSObject>
@optional
- (void)onIsRecordingActiveChanged:(ACSRecordingCallFeature * _Nonnull)recordingCallFeature :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( recordingCallFeature(_:didChangeRecordingState:));
- (void)onRecordingUpdated:(ACSRecordingCallFeature * _Nonnull)recordingCallFeature :(ACSRecordingUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( recordingCallFeature(_:didUpdateRecording:));
@end

/**
 * A set of methods that are called by ACSTranscriptionCallFeature in response to important events.
 */
NS_SWIFT_NAME(TranscriptionCallFeatureDelegate)
@protocol ACSTranscriptionCallFeatureDelegate <NSObject>
@optional
- (void)onIsTranscriptionActiveChanged:(ACSTranscriptionCallFeature * _Nonnull)transcriptionCallFeature :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( transcriptionCallFeature(_:didChangeTranscriptionState:));
@end

/**
 * A set of methods that are called by ACSTeamsCaptionsCallFeature in response to important events.
 */
NS_SWIFT_NAME(TeamsCaptionsCallFeatureDelegate)
@protocol ACSTeamsCaptionsCallFeatureDelegate <NSObject>
@optional
- (void)onCaptionsActiveChanged:(ACSTeamsCaptionsCallFeature * _Nonnull)teamsCaptionsCallFeature :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( teamsCaptionsCallFeature(_:didChangeCaptionsActiveState:));
- (void)onCaptionsReceived:(ACSTeamsCaptionsCallFeature * _Nonnull)teamsCaptionsCallFeature :(ACSTeamsCaptionsInfo * _Nonnull)captionsInfo NS_SWIFT_NAME( teamsCaptionsCallFeature(_:didReceiveCaptions:));
@end

/**
 * A set of methods that are called by ACSDominantSpeakersCallFeature in response to important events.
 */
NS_SWIFT_NAME(DominantSpeakersCallFeatureDelegate)
@protocol ACSDominantSpeakersCallFeatureDelegate <NSObject>
@optional
- (void)onDominantSpeakersChanged:(ACSDominantSpeakersCallFeature * _Nonnull)dominantSpeakersCallFeature :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( dominantSpeakersCallFeature(_:didChangeDominantSpeakers:));
@end

/**
 * A set of methods that are called by ACSRaiseHandCallFeature in response to important events.
 */
NS_SWIFT_NAME(RaiseHandCallFeatureDelegate)
@protocol ACSRaiseHandCallFeatureDelegate <NSObject>
@optional
- (void)onRaisedHandReceived:(ACSRaiseHandCallFeature * _Nonnull)raiseHandCallFeature :(ACSRaisedHandChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( raiseHandCallFeature(_:didReceiveRaisedHand:));
- (void)onLoweredHandReceived:(ACSRaiseHandCallFeature * _Nonnull)raiseHandCallFeature :(ACSRaisedHandChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( raiseHandCallFeature(_:didReceiveLoweredHand:));
@end

/**
 * A set of methods that are called by ACSRawOutgoingVideoStreamOptions in response to important events.
 */
NS_SWIFT_NAME(RawOutgoingVideoStreamOptionsDelegate)
@protocol ACSRawOutgoingVideoStreamOptionsDelegate <NSObject>
@optional
- (void)onVideoFrameSenderChanged:(ACSRawOutgoingVideoStreamOptions * _Nonnull)rawOutgoingVideoStreamOptions :(ACSVideoFrameSenderChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(rawOutgoingVideoStreamOptions(_:didChangeVideoFrameSender:));
- (void)onOutgoingVideoStreamStateChanged:(ACSRawOutgoingVideoStreamOptions * _Nonnull)rawOutgoingVideoStreamOptions :(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(rawOutgoingVideoStreamOptions(_:didChangeOutgoingVideoStreamState:));
@end

/**
 * A set of methods that are called by ACSScreenShareRawOutgoingVideoStream in response to important events.
 */
NS_SWIFT_NAME(ScreenShareRawOutgoingVideoStreamDelegate)
@protocol ACSScreenShareRawOutgoingVideoStreamDelegate <NSObject>
@optional
- (void)onOutgoingVideoStreamStateChanged:(ACSScreenShareRawOutgoingVideoStream * _Nonnull)screenShareRawOutgoingVideoStream :(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( screenShareRawOutgoingVideoStream(_:didChangeOutgoingVideoStreamState:));
@end

/**
 * A set of methods that are called by ACSVirtualRawOutgoingVideoStream in response to important events.
 */
NS_SWIFT_NAME(VirtualRawOutgoingVideoStreamDelegate)
@protocol ACSVirtualRawOutgoingVideoStreamDelegate <NSObject>
@optional
- (void)onOutgoingVideoStreamStateChanged:(ACSVirtualRawOutgoingVideoStream * _Nonnull)virtualRawOutgoingVideoStream :(ACSOutgoingVideoStreamStateChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( virtualRawOutgoingVideoStream(_:didChangeOutgoingVideoStreamState:));
@end

/**
 * A set of methods that are called by ACSNetworkDiagnostics in response to important events.
 */
NS_SWIFT_NAME(NetworkDiagnosticsDelegate)
@protocol ACSNetworkDiagnosticsDelegate <NSObject>
@optional
- (void)onNoNetworkChanged:(ACSNetworkDiagnostics * _Nonnull)networkDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(networkDiagnostics(_:didChangeNoNetworkValue:));
- (void)onNetworkRelaysNotReachableChanged:(ACSNetworkDiagnostics * _Nonnull)networkDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(networkDiagnostics(_:didChangeNetworkRelaysNotReachableValue:));
- (void)onNetworkReconnectChanged:(ACSNetworkDiagnostics * _Nonnull)networkDiagnostics :(ACSQualityDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(networkDiagnostics(_:didChangeNetworkReconnectValue:));
- (void)onNetworkReceiveQualityChanged:(ACSNetworkDiagnostics * _Nonnull)networkDiagnostics :(ACSQualityDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(networkDiagnostics(_:didChangeNetworkReceiveQualityValue:));
- (void)onNetworkSendQualityChanged:(ACSNetworkDiagnostics * _Nonnull)networkDiagnostics :(ACSQualityDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(networkDiagnostics(_:didChangeNetworkSendQualityValue:));
@end

/**
 * A set of methods that are called by ACSMediaDiagnostics in response to important events.
 */
NS_SWIFT_NAME(MediaDiagnosticsDelegate)
@protocol ACSMediaDiagnosticsDelegate <NSObject>
@optional
- (void)onSpeakerNotFunctioningChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeSpeakerNotFunctioningValue:));
- (void)onSpeakerNotFunctioningDeviceInUseChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeSpeakerNotFunctioningDeviceInUseValue:));
- (void)onSpeakerMutedChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeSpeakerMutedValue:));
- (void)onSpeakerVolumeIsZeroChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeSpeakerVolumeIsZeroValue:));
- (void)onNoSpeakerDevicesEnumeratedChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeNoSpeakerDevicesEnumeratedValue:));
- (void)onSpeakingWhileMicrophoneIsMutedChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeSpeakingWhileMicrophoneIsMutedValue:));
- (void)onNoMicrophoneDevicesEnumeratedChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeNoMicrophoneDevicesEnumeratedValue:));
- (void)onMicrophoneNotFunctioningDeviceInUseChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeMicrophoneNotFunctioningDeviceInUseValue:));
- (void)onCameraFreezeChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeCameraFreezeValue:));
- (void)onCameraStartFailedChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeCameraStartFailedValue:));
- (void)onCameraStartTimedOutChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeCameraStartTimedOutValue:));
- (void)onMicrophoneNotFunctioningChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeMicrophoneNotFunctioningValue:));
- (void)onMicrophoneMuteUnexpectedlyChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeMicrophoneMuteUnexpectedlyValue:));
- (void)onCameraPermissionDeniedChanged:(ACSMediaDiagnostics * _Nonnull)mediaDiagnostics :(ACSFlagDiagnosticChangedEventArgs * _Nonnull)args NS_SWIFT_NAME(mediaDiagnostics(_:didChangeCameraPermissionDeniedValue:));
@end

/// Contains information about common properties between different types of outgoing video streams
NS_SWIFT_NAME(OutgoingVideoStream)
@interface ACSOutgoingVideoStream : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Informs the current running state of this OutgoingStream. It might change during the call due network conditions or other events.
@property (readonly) ACSMediaStreamType mediaStreamType;

/// Informs the type of the OutgoingVideoStream between all the available types.
@property (readonly) ACSOutgoingVideoStreamKind outgoingVideoStreamKind;

/// Informs the current running state of this OutgoingStream. It might change during the call due network conditions or other events.
@property (readonly) ACSOutgoingVideoStreamState outgoingVideoStreamState;

@end

/// Property bag class for Video Options. Use this class to set video options required during a call (start/accept/join)
NS_SWIFT_NAME(VideoOptions)
@interface ACSVideoOptions : NSObject
-(nonnull instancetype)init:(NSArray<ACSOutgoingVideoStream *> * _Nonnull )outgoingVideoStreams NS_SWIFT_NAME(init(outgoingVideoStreams:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The video stream that is used to render the video on the UI surface
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * localVideoStreams;

// Class extension begins for VideoOptions.
-(nonnull instancetype)initWithLocalVideoStreams:(NSArray<ACSLocalVideoStream *> * _Nonnull )localVideoStreams NS_SWIFT_NAME( init(localVideoStreams:));
// Class extension ends for VideoOptions.

@end

/// Local video stream information
NS_SWIFT_NAME(LocalVideoStream)
@interface ACSLocalVideoStream : ACSOutgoingVideoStream
-(nonnull instancetype)init:(ACSVideoDeviceInfo * _Nonnull )camera NS_SWIFT_NAME( init(camera:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// Video device to use as source for local video.
@property (retain, nonnull, readonly) ACSVideoDeviceInfo * source;

/// Sets to True when the local video stream is being sent on a call.
@property (readonly) BOOL isSending;

/**
 * The delegate that will handle events from the ACSLocalVideoStream.
 */
@property(nonatomic, weak, nullable) id<ACSLocalVideoStreamDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSLocalVideoStream.
 */
@property(nonatomic, strong, nonnull, readonly) ACSLocalVideoStreamEvents *events;

// Class extension begins for LocalVideoStream.
-(void)switchSource:(ACSVideoDeviceInfo* _Nonnull)camera withCompletionHandler:(void (^ _Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( switchSource(camera:completionHandler:));
// Class extension ends for LocalVideoStream.

@end

/// Information about a video device
NS_SWIFT_NAME(VideoDeviceInfo)
@interface ACSVideoDeviceInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get the name of this video device.
@property (retain, nonnull, readonly) NSString * name;

/// Get Name of this audio device.
@property (retain, nonnull, readonly) NSString * id;

/// Direction of the camera
@property (readonly) ACSCameraFacing cameraFacing;

/// Get the Device Type of this video device.
@property (readonly) ACSVideoDeviceType deviceType;

@end

/// Describes an OutgoingStreamStateChanged event data.
NS_SWIFT_NAME(OutgoingVideoStreamStateChangedEventArgs)
@interface ACSOutgoingVideoStreamStateChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Informs the current running state of this OutgoingVideoStream. It might change during the call due network conditions or other events.
@property (readonly) ACSOutgoingVideoStreamState outgoingVideoStreamState;

/// Contains an important message about the functioning of the OutgoingVideoStream.
@property (retain, nonnull, readonly) NSString * message;

@end

/// Property bag class for Audio Options. Use this class to set audio settings required during a call (start/join)
NS_SWIFT_NAME(AudioOptions)
@interface ACSAudioOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Start an outgoing or accept incoming call muted (true) or un-muted(false)
@property BOOL muted DEPRECATED_MSG_ATTRIBUTE("Deprecated use outgoingAudioMuted instead");

@property BOOL outgoingAudioMuted;

/// Start an outgoing or accept incoming call speaker muted (true) or un-muted(false)
@property BOOL incomingAudioMuted;

@property (retain, nullable) ACSIncomingAudioStream * incomingAudioStream;

@property (retain, nullable) ACSOutgoingAudioStream * outgoingAudioStream;

@end

NS_SWIFT_NAME(AudioStream)
@interface ACSAudioStream : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Informs the kind of the Audio Stream.
@property (readonly) ACSAudioStreamKind audioStreamKind;

@end

NS_SWIFT_NAME(IncomingAudioStream)
@interface ACSIncomingAudioStream : ACSAudioStream
-(nonnull instancetype)init NS_UNAVAILABLE;
@end

NS_SWIFT_NAME(OutgoingAudioStream)
@interface ACSOutgoingAudioStream : ACSAudioStream
-(nonnull instancetype)init NS_UNAVAILABLE;
@end

/// Options to be passed when joining a call
NS_SWIFT_NAME(JoinCallOptions)
@interface ACSJoinCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when placing a call
@property (retain, nullable) ACSVideoOptions * videoOptions;

/// Audio options when placing a call
@property (retain, nullable) ACSAudioOptions * audioOptions;

// Class extension begins for JoinCallOptions.
@property(nullable) ACSCallKitRemoteInfo* callKitRemoteInfo;
// Class extension ends for JoinCallOptions.

@end

/// Options to be passed when accepting a call
NS_SWIFT_NAME(AcceptCallOptions)
@interface ACSAcceptCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when accepting a call
@property (retain, nonnull) ACSVideoOptions * videoOptions;

/// Audio options when placing a call
@property (retain, nullable) ACSAudioOptions * audioOptions;

@end

/// Options to be passed when starting a call
NS_SWIFT_NAME(StartCallOptions)
@interface ACSStartCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when starting a call
@property (retain, nullable) ACSVideoOptions * videoOptions;

/// Audio options when starting a call
@property (retain, nullable) ACSAudioOptions * audioOptions;

// Class extension begins for StartCallOptions.
@property(nonatomic, nonnull) PhoneNumberIdentifier* alternateCallerId;
@property(nullable) ACSCallKitRemoteInfo* callKitRemoteInfo;
// Class extension ends for StartCallOptions.

@end

/// Options when making an outgoing PSTN call
NS_SWIFT_NAME(AddPhoneNumberOptions)
@interface ACSAddPhoneNumberOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

// Class extension begins for AddPhoneNumberOptions.
@property(nonatomic, nonnull) PhoneNumberIdentifier* alternateCallerId;
// Class extension ends for AddPhoneNumberOptions.

@end

/// JoinMeetingLocator super type, locator for joining meetings
NS_SWIFT_NAME(JoinMeetingLocator)
@interface ACSJoinMeetingLocator : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

@end

/// Options for joining a group call
NS_SWIFT_NAME(GroupCallLocator)
@interface ACSGroupCallLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSUUID * _Nonnull )groupId NS_SWIFT_NAME( init(groupId:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The unique identifier for the group conversation
@property (retain, nonnull, readonly) NSUUID *groupId;

@end

/// Options for joining a Teams meeting using Coordinates locator
NS_SWIFT_NAME(TeamsMeetingCoordinatesLocator)
@interface ACSTeamsMeetingCoordinatesLocator : ACSJoinMeetingLocator
-(nonnull instancetype)initWithThreadId:(NSString * _Nonnull )threadId organizerId:(NSUUID * _Nonnull )organizerId tenantId:(NSUUID * _Nonnull )tenantId messageId:(NSString * _Nonnull )messageId NS_SWIFT_NAME( init(withThreadId:organizerId:tenantId:messageId:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The thread identifier of meeting
@property (retain, nonnull, readonly) NSString * threadId;

/// The organizer identifier of meeting
@property (retain, nonnull, readonly) NSUUID *organizerId;

/// The tenant identifier of meeting
@property (retain, nonnull, readonly) NSUUID *tenantId;

/// The message identifier of meeting
@property (retain, nonnull, readonly) NSString * messageId;

@end

/// Options for joining a Teams meeting using Link locator
NS_SWIFT_NAME(TeamsMeetingLinkLocator)
@interface ACSTeamsMeetingLinkLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSString * _Nonnull )meetingLink NS_SWIFT_NAME( init(meetingLink:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The URI of the meeting
@property (retain, nonnull, readonly) NSString * meetingLink;

@end

/// Describes the Caller Information
NS_SWIFT_NAME(CallerInfo)
@interface ACSCallerInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The display name of the caller
@property (retain, nonnull, readonly) NSString * displayName;

// Class extension begins for CallerInfo.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for CallerInfo.

@end

/// Describes an incoming call
NS_SWIFT_NAME(PushNotificationInfo)
@interface ACSPushNotificationInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The display name of the caller
@property (retain, nonnull, readonly) NSString * fromDisplayName;

/// Indicates whether the incoming call has a video or not
@property (readonly) BOOL incomingWithVideo;

@property (readonly) ACSPushNotificationEventType eventType;

// Class extension begins for PushNotificationInfo.
@property (retain, readonly, nonnull) id<CommunicationIdentifier> from;
@property (retain, readonly, nonnull) id<CommunicationIdentifier> to;
@property (nonatomic, readonly, nonnull) NSUUID* callId;
+(ACSPushNotificationInfo* _Nonnull) fromDictionary:(NSDictionary* _Nonnull)payload;
// Class extension ends for PushNotificationInfo.

@end

/// Options for creating CallAgent
NS_SWIFT_NAME(CallAgentOptions)
@interface ACSCallAgentOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Specify the display name of the local participant for all new calls
@property (retain, nonnull) NSString * displayName;

/// Emergency call options when creating a call agent
@property (retain, nullable) ACSEmergencyCallOptions * emergencyCallOptions;

// Class extension begins for CallAgentOptions.
@property(retain, nullable) ACSCallKitOptions* callKitOptions;
// Class extension ends for CallAgentOptions.

@end

/// Options for emergency call of call agent
NS_SWIFT_NAME(EmergencyCallOptions)
@interface ACSEmergencyCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Specify the ISO 3166-1 alpha-2 emergency country code of the local participant for emergency calls
@property (retain, nonnull) NSString * countryCode;

@end

/// Call agent created by the CallClient factory method createCallAgent It bears the responsibility of managing calls on behalf of the authenticated user
NS_SWIFT_NAME(CallAgent)
@interface ACSCallAgent : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Returns the list of all active calls.
@property (copy, nonnull, readonly) NSArray<ACSCall *> * calls;

/**
 * The delegate that will handle events from the ACSCallAgent.
 */
@property(nonatomic, weak, nullable) id<ACSCallAgentDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSCallAgent.
 */
@property(nonatomic, strong, nonnull, readonly) ACSCallAgentEvents *events;

/// Releases all the resources held by CallAgent. CallAgent should be destroyed/nullified after dispose. Closes this resource. This gets projected to java.lang.AutoCloseable.close() in Java projection.
-(void)dispose;

/// Unregister all previously registered devices from receiving incoming calls push notifications.
-(void)unregisterPushNotificationWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( unregisterPushNotification(completionHandler:));

// Class extension begins for CallAgent.
-(void)startCall:(NSArray<id<CommunicationIdentifier>>* _Nonnull)participants
            options:(ACSStartCallOptions* _Nullable)options
withCompletionHandler:(void (^ _Nonnull)(ACSCall* _Nullable call, NSError* _Nullable error))completionHandler NS_SWIFT_NAME( startCall(participants:options:completionHandler:));
-(void)joinWithMeetingLocator:(ACSJoinMeetingLocator* _Nonnull)meetingLocator
              joinCallOptions:(ACSJoinCallOptions* _Nullable)joinCallOptions
withCompletionHandler:(void (^ _Nonnull)(ACSCall* _Nullable call, NSError* _Nullable error))completionHandler NS_SWIFT_NAME( join(with:joinCallOptions:completionHandler:));
-(void)registerPushNotifications: (NSData* _Nonnull)deviceToken withCompletionHandler:(void (^ _Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( registerPushNotifications(deviceToken:completionHandler:));
-(void)handlePushNotification:(ACSPushNotificationInfo* _Nonnull)notification withCompletionHandler:(void (^_Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( handlePush(notification:completionHandler:));
// Class extension ends for CallAgent.

@end

/// Describes a call
NS_SWIFT_NAME(Call)
@interface ACSCall : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get a list of remote participants in the current call. In case of calls with participants of hundred or more, only media active participants are present in this collection.
@property (copy, nonnull, readonly) NSArray<ACSRemoteParticipant *> * remoteParticipants;

/// Id of the call
@property (retain, nonnull, readonly) NSString * id;

/// Current state of the call
@property (readonly) ACSCallState state;

/// Containing code/subcode indicating how a call has ended
@property (retain, nonnull, readonly) ACSCallEndReason * callEndReason;

/// Outgoing or Incoming depending on the Call Direction
@property (readonly) ACSCallDirection direction;

/// Information about the caller
@property (retain, nonnull, readonly) ACSCallInfo * info;

/// Whether the local microphone is muted or not.
@property (readonly) BOOL isMuted DEPRECATED_MSG_ATTRIBUTE("Deprecated use isOutgoingAudioMuted instead");

@property (readonly) BOOL isOutgoingAudioMuted;

/// Whether the local speaker is muted or not.
@property (readonly) BOOL isIncomingAudioMuted;

/// The identity of the caller
@property (retain, nonnull, readonly) ACSCallerInfo * callerInfo;

/// Participant role in the call
@property (readonly) ACSParticipantRole role;

/// Get a list of local video streams in the current call.
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * localVideoStreams;

/// Total number of participants active in the current call
@property (readonly) int totalParticipantCount;

/**
 * The delegate that will handle events from the ACSCall.
 */
@property(nonatomic, weak, nullable) id<ACSCallDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSCall.
 */
@property(nonatomic, strong, nonnull, readonly) ACSCallEvents *events;

/// Start audio stream
-(void)startAudio:(ACSAudioStream * _Nonnull )stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( startAudio(stream:completionHandler:));

/// Stop audio stream
-(void)stopAudio:(ACSMediaStreamDirection)direction withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( stopAudio(direction:completionHandler:));

/// Mute local microphone.
-(void)muteWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( mute(completionHandler:)) DEPRECATED_MSG_ATTRIBUTE("Deprecated use updateOutgoingAudio(mute:) instead");

/// Mutes/Unmutes speaker.
-(void)updateIncomingAudio:(BOOL)mute withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( updateIncomingAudio(mute:completionHandler:));

/// Mutes/Unmutes microphone.
-(void)updateOutgoingAudio:(BOOL)mute withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( updateOutgoingAudio(mute:completionHandler:));

/// Unmute local microphone.
-(void)unmuteWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( unmute(completionHandler:)) DEPRECATED_MSG_ATTRIBUTE("Deprecated use updateOutgoingAudio(mute:) instead");

/// Send DTMF tone
-(void)sendDtmf:(ACSDtmfTone)tone withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( sendDtmf(tone:completionHandler:));

/// Start sharing video stream to the call
-(void)startVideo:(ACSOutgoingVideoStream * _Nonnull )stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( startVideo(stream:completionHandler:));

/// Stop sharing video stream to the call
-(void)stopVideo:(ACSOutgoingVideoStream * _Nonnull )stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( stopVideo(stream:completionHandler:));

/// HangUp a call
-(void)hangUp:(ACSHangUpOptions * _Nullable )options withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( hangUp(options:completionHandler:));

/// Remove a participant from a call
-(void)removeParticipant:(ACSRemoteParticipant * _Nonnull )participant withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( remove(participant:completionHandler:));

/// Hold this call
-(void)holdWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( hold(completionHandler:));

/// Resume this call
-(void)resumeWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( resume(completionHandler:));

// Class extension begins for Call.
-(ACSRemoteParticipant* _Nullable)addParticipant:(id<CommunicationIdentifier> _Nonnull)participant withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( add(participant:));
-(ACSRemoteParticipant* _Nullable)addParticipant:(PhoneNumberIdentifier* _Nonnull) participant options:(ACSAddPhoneNumberOptions* _Nullable)options withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( add(participant:options:));

-(id _Nonnull)feature: (Class _Nonnull)featureClass NS_REFINED_FOR_SWIFT;
// Class extension ends for Call.

@end

/// Describes a remote participant on a call
NS_SWIFT_NAME(RemoteParticipant)
@interface ACSRemoteParticipant : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Private Preview Only: Display Name of the remote participant
@property (retain, nonnull, readonly) NSString * displayName;

/// Public Preview Only: Role of the remote participant
@property (readonly) ACSParticipantRole role;

/// True if the remote participant is muted
@property (readonly) BOOL isMuted;

/// True if the remote participant is speaking. Only applicable to multi-party calls
@property (readonly) BOOL isSpeaking;

/// Reason why participant left the call, contains code/subcode.
@property (retain, nonnull, readonly) ACSCallEndReason * callEndReason;

/// Current state of the remote participant
@property (readonly) ACSParticipantState state;

/// Remote Video streams part of the current call
@property (copy, nonnull, readonly) NSArray<ACSRemoteVideoStream *> * videoStreams;

/**
 * The delegate that will handle events from the ACSRemoteParticipant.
 */
@property(nonatomic, weak, nullable) id<ACSRemoteParticipantDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSRemoteParticipant.
 */
@property(nonatomic, strong, nonnull, readonly) ACSRemoteParticipantEvents *events;

// Class extension begins for RemoteParticipant.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for RemoteParticipant.

@end

/// Describes the reason for a call to end
NS_SWIFT_NAME(CallEndReason)
@interface ACSCallEndReason : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The code
@property (readonly) int code;

/// The subcode
@property (readonly) int subcode;

@end

/// Video stream on remote participant
NS_SWIFT_NAME(RemoteVideoStream)
@interface ACSRemoteVideoStream : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// True when remote video stream is available.
@property (readonly) BOOL isAvailable;

/// MediaStream type of the current remote video stream (Video or ScreenShare).
@property (readonly) ACSMediaStreamType mediaStreamType;

/// Unique Identifier of the current remote video stream.
@property (readonly) int id;


@end

/// Describes a PropertyChanged event data
NS_SWIFT_NAME(PropertyChangedEventArgs)
@interface ACSPropertyChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

@end

/// Information about remote video streams added or removed
NS_SWIFT_NAME(RemoteVideoStreamsEventArgs)
@interface ACSRemoteVideoStreamsEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Remote video streams that have been added to the current call
@property (copy, nonnull, readonly) NSArray<ACSRemoteVideoStream *> * addedRemoteVideoStreams;

/// Remote video streams that are no longer part of the current call
@property (copy, nonnull, readonly) NSArray<ACSRemoteVideoStream *> * removedRemoteVideoStreams;

@end

/// Describes a call's information
NS_SWIFT_NAME(CallInfo)
@interface ACSCallInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

-(void)getServerCallIdWithCompletionHandler:(void (^ _Nonnull )(NSString * _Nullable  value, NSError * _Nullable error))completionHandler NS_SWIFT_NAME( getServerCallId(completionHandler:));

@end

/// Describes a ParticipantsUpdated event data
NS_SWIFT_NAME(ParticipantsUpdatedEventArgs)
@interface ACSParticipantsUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// List of Participants that were added
@property (copy, nonnull, readonly) NSArray<ACSRemoteParticipant *> * addedParticipants;

/// List of Participants that were removed
@property (copy, nonnull, readonly) NSArray<ACSRemoteParticipant *> * removedParticipants;

@end

/// Describes a LocalVideoStreamsUpdated event data
NS_SWIFT_NAME(LocalVideoStreamsUpdatedEventArgs)
@interface ACSLocalVideoStreamsUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// List of LocalVideoStream that were added
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * addedStreams;

/// List of LocalVideoStream that were removed
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * removedStreams;

@end

/// Property bag class for hanging up a call
NS_SWIFT_NAME(HangUpOptions)
@interface ACSHangUpOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Use to determine whether the current call should be terminated for all participant on the call or not
@property BOOL forEveryone;

@end

/// CallFeature super type, features extensions for call.
NS_SWIFT_NAME(CallFeature)
@interface ACSCallFeature : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Name of the extended CallFeature.
@property (retain, nonnull, readonly) NSString * name;

@end

/// Describes a CallsUpdated event
NS_SWIFT_NAME(CallsUpdatedEventArgs)
@interface ACSCallsUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// New calls being tracked by the library
@property (copy, nonnull, readonly) NSArray<ACSCall *> * addedCalls;

/// Calls that are no longer tracked by the library
@property (copy, nonnull, readonly) NSArray<ACSCall *> * removedCalls;

@end

/// Describes an incoming call
NS_SWIFT_NAME(IncomingCall)
@interface ACSIncomingCall : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Describe the reason why a call has ended
@property (retain, nullable, readonly) ACSCallEndReason * callEndReason;

/// Information about the caller
@property (retain, nonnull, readonly) ACSCallerInfo * callerInfo;

/// Id of the call
@property (retain, nonnull, readonly) NSString * id;

/// Is incoming video enabled
@property (readonly) BOOL isVideoEnabled;

/**
 * The delegate that will handle events from the ACSIncomingCall.
 */
@property(nonatomic, weak, nullable) id<ACSIncomingCallDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSIncomingCall.
 */
@property(nonatomic, strong, nonnull, readonly) ACSIncomingCallEvents *events;

/// Accept an incoming call
-(void)accept:(ACSAcceptCallOptions * _Nonnull )options withCompletionHandler:(void (^ _Nonnull )(ACSCall * _Nullable  value, NSError * _Nullable error))completionHandler NS_SWIFT_NAME( accept(options:completionHandler:));

/// Reject this incoming call
-(void)rejectWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( reject(completionHandler:));

@end

/// This is the main class representing the entrypoint for the Calling SDK.
NS_SWIFT_NAME(CallClient)
@interface ACSCallClient : NSObject
-(nonnull instancetype)init;

-(nonnull instancetype)init:(ACSCallClientOptions * _Nonnull )options NS_SWIFT_NAME( init(options:));

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Releases all the resources held by CallClient. CallClient should be destroyed/nullified after dispose.
-(void)dispose;

// Class extension begins for CallClient.
-(void)createCallAgent:(CommunicationTokenCredential* _Nonnull) userCredential
 withCompletionHandler:(void (^ _Nonnull)(ACSCallAgent* _Nullable clientAgent,
                                          NSError * _Nullable error))completionHandler NS_SWIFT_NAME( createCallAgent(userCredential:completionHandler:));

-(void)createCallAgentWithOptions:(CommunicationTokenCredential* _Nonnull) userCredential
                 callAgentOptions:(ACSCallAgentOptions* _Nullable) callAgentOptions
            withCompletionHandler:(void (^ _Nonnull)(ACSCallAgent* _Nullable clientAgent,
                                                     NSError* _Nullable error))completionHandler NS_SWIFT_NAME( createCallAgent(userCredential:options:completionHandler:));

+(void)reportIncomingCallFromKillState:(ACSPushNotificationInfo* _Nonnull)payload
                    callKitOptions:(ACSCallKitOptions* _Nonnull) callKitOptions
             withCompletionHandler:(void (^ _Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( reportIncomingCallFromKillState(with:callKitOptions:completionHandler:));

-(void)getDeviceManagerWithCompletionHandler:(void (^ _Nonnull)(ACSDeviceManager* _Nullable value,
                                                                NSError* _Nullable error))completionHandler NS_SWIFT_NAME( getDeviceManager(completionHandler:));

@property (retain, nonnull) CommunicationTokenCredential* communicationCredential;
// Class extension ends for CallClient.

@end

/// Options to be passed when creating a call client
NS_SWIFT_NAME(CallClientOptions)
@interface ACSCallClientOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Call Diagnostics options when creating a call client
@property (retain, nullable) ACSCallDiagnosticsOptions * diagnostics;

@end

/// Options for diagnostics of call client
NS_SWIFT_NAME(CallDiagnosticsOptions)
@interface ACSCallDiagnosticsOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// An Identifier to group together multiple appIds into small bundle, invariant of version.
@property (retain, nonnull) NSString * appName;

/// The application version.
@property (retain, nonnull) NSString * appVersion;

/// Tags - additonal information.
@property (copy, nonnull) NSArray<NSString *> * tags;

@end

/// Device manager
NS_SWIFT_NAME(DeviceManager)
@interface ACSDeviceManager : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get the list of currently connected video devices
@property (copy, nonnull, readonly) NSArray<ACSVideoDeviceInfo *> * cameras;

/**
 * The delegate that will handle events from the ACSDeviceManager.
 */
@property(nonatomic, weak, nullable) id<ACSDeviceManagerDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSDeviceManager.
 */
@property(nonatomic, strong, nonnull, readonly) ACSDeviceManagerEvents *events;

@end

/// Describes a VideoDevicesUpdated event data
NS_SWIFT_NAME(VideoDevicesUpdatedEventArgs)
@interface ACSVideoDevicesUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video devicesRemote video streams that have been added to the current call
@property (copy, nonnull, readonly) NSArray<ACSVideoDeviceInfo *> * addedVideoDevices;

/// Remote video streams that have been added to the current call
@property (copy, nonnull, readonly) NSArray<ACSVideoDeviceInfo *> * removedVideoDevices;

@end

/// Describes a RecordingUpdated event data
NS_SWIFT_NAME(RecordingUpdatedEventArgs)
@interface ACSRecordingUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The recording that was added or removed
@property (retain, nonnull, readonly) ACSRecordingInfo * updatedRecording;

@end

/// The state of an existing recording
NS_SWIFT_NAME(RecordingInfo)
@interface ACSRecordingInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Indicates the state of current recording
@property (readonly) ACSRecordingState state;

@end

/// Call Feature for managing call recording
NS_SWIFT_NAME(RecordingCallFeature)
@interface ACSRecordingCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Indicates if recording is active in current call
@property (readonly) BOOL isRecordingActive;

/// The list of current recordings
@property (copy, nonnull, readonly) NSArray<ACSRecordingInfo *> * recordings;

/**
 * The delegate that will handle events from the ACSRecordingCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSRecordingCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSRecordingCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSRecordingCallFeatureEvents *events;

@end

/// Call Feature for managing call transcription
NS_SWIFT_NAME(TranscriptionCallFeature)
@interface ACSTranscriptionCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Indicates if transcription is active in current call
@property (readonly) BOOL isTranscriptionActive;

/**
 * The delegate that will handle events from the ACSTranscriptionCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSTranscriptionCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSTranscriptionCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSTranscriptionCallFeatureEvents *events;

@end

/// Call Feature for managing captions for a teams interop call.
NS_SWIFT_NAME(TeamsCaptionsCallFeature)
@interface ACSTeamsCaptionsCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
@property (copy, nonnull, readonly) NSArray<NSString *> * supportedSpokenLanguages;

@property (copy, nonnull, readonly) NSArray<NSString *> * supportedCaptionLanguages;

/// Indicates if captions is active in current call.
@property (readonly) BOOL isCaptionsFeatureActive;

/**
 * The delegate that will handle events from the ACSTeamsCaptionsCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSTeamsCaptionsCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSTeamsCaptionsCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSTeamsCaptionsCallFeatureEvents *events;

/// Starts the captions.
-(void)startCaptions:(ACSStartCaptionsOptions * _Nullable )options withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( startCaptions(options:completionHandler:));

/// Stop the captions.
-(void)stopCaptionsWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( stopCaptions(completionHandler:));

/// Set the spoken language.
-(void)setSpokenLanguage:(NSString * _Nonnull )language withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( set(spokenLanguage:completionHandler:));

/// Set the captions language.
-(void)setCaptionLanguage:(NSString * _Nonnull )language withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( set(captionLanguage:completionHandler:));

@end

NS_SWIFT_NAME(StartCaptionsOptions)
@interface ACSStartCaptionsOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// language in which the speaker is speaking.
@property (retain, nonnull) NSString * spokenLanguage;

@end

/// Captions details for teams captions call feature.
NS_SWIFT_NAME(TeamsCaptionsInfo)
@interface ACSTeamsCaptionsInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Information about the speaker.
@property (retain, nonnull, readonly) ACSCallerInfo * speaker;

/// The original text with no transcribed.
@property (retain, nonnull, readonly) NSString * spokenText;

/// language identifier for the speaker.
@property (retain, nonnull, readonly) NSString * spokenLanguage;

/// The transcribed text.
@property (retain, nonnull, readonly) NSString * captionText;

/// language identifier for the captions text.
@property (retain, nonnull, readonly) NSString * captionLanguage;

/// CaptionsResultType is Intermediate if text contains partially spoken sentence. It is set to final once the sentence has been completely transcribed.
@property (readonly) ACSCaptionsResultType resultType;

/// Timestamp denoting the time when the corresponding speech was made. timestamp is received from call recorder in C# ticks since 1/1/1900 (NTP Epoch) timestamp is converted to ms since 1/1/1970 (UNIX Epoch) 10000 C# ticks / 1 ms
@property (retain, nonnull, readonly) NSDate * timestamp;

@end

/// Call Feature for managing the dominant speakers of a call
NS_SWIFT_NAME(DominantSpeakersCallFeature)
@interface ACSDominantSpeakersCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Information about the dominant speakers of the call
@property (retain, nonnull, readonly) ACSDominantSpeakersInfo * dominantSpeakersInfo;

/**
 * The delegate that will handle events from the ACSDominantSpeakersCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSDominantSpeakersCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSDominantSpeakersCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSDominantSpeakersCallFeatureEvents *events;

@end

/// Information about the dominant speakers of a call
NS_SWIFT_NAME(DominantSpeakersInfo)
@interface ACSDominantSpeakersInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Last updated time of the current dominant speakers list
@property (retain, nonnull, readonly) NSDate * lastUpdatedAt NS_SWIFT_NAME(lastUpdated);

// Class extension begins for DominantSpeakersInfo.
/// List of the current dominant speakers
@property(nonatomic, readonly, nonnull) NSArray<id<CommunicationIdentifier>> * speakers;
// Class extension ends for DominantSpeakersInfo.

@end

/// Call Feature for managing raise hand states for a call.
NS_SWIFT_NAME(RaiseHandCallFeature)
@interface ACSRaiseHandCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
@property (copy, nonnull, readonly) NSArray<ACSRaisedHand *> * raisedHands;

/**
 * The delegate that will handle events from the ACSRaiseHandCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSRaiseHandCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSRaiseHandCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSRaiseHandCallFeatureEvents *events;

/// Send request to raise hand for local user.
-(void)raiseHandWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( raiseHand(completionHandler:));

/// Send request to lower hand for local user.
-(void)lowerHandWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( lowerHand(completionHandler:));

/// Send request to lower raise hand raise status for every user on the call.
-(void)lowerAllHandsWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( lowerAllHands(completionHandler:));

// Class extension begins for RaiseHandCallFeature.
-(void)lowerHands:(NSArray<id<CommunicationIdentifier>>* _Nonnull)participants
withCompletionHandler:(void (^ _Nonnull)(NSError *error))completionHandler NS_SWIFT_NAME( lowerHands(participants:completionHandler:));
// Class extension ends for RaiseHandCallFeature.

@end

/// Raise hand details for Call.
NS_SWIFT_NAME(RaisedHand)
@interface ACSRaisedHand : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Order of raise hand events.
@property (readonly) int order;

// Class extension begins for RaisedHand.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for RaisedHand.

@end

/// Raise hand details for Call.
NS_SWIFT_NAME(RaisedHandChangedEventArgs)
@interface ACSRaisedHandChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

// Class extension begins for RaisedHandChangedEventArgs.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for RaisedHandChangedEventArgs.

@end

/// Options to be passed when rendering a Video
NS_SWIFT_NAME(CreateViewOptions)
@interface ACSCreateViewOptions : NSObject
-(nonnull instancetype)init:(ACSScalingMode)scalingMode NS_SWIFT_NAME( init(scalingMode:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Scaling mode for rendering the video.
@property ACSScalingMode scalingMode;

@end

/// Describes details of the video frame content that the application is capable of generating. ACS Calling SDK will dynamically select the VideoFormat best matching with network conditions at runtime.
NS_SWIFT_NAME(VideoFormat)
@interface ACSVideoFormat : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Total width-wise count of pixels of the video frame. It must be greater or equal to 240 and less or equal to 1920. Values greater than 1280 and aspect ratios other than 16:9 or 4:3 might be adjusted by the SDK consuming extra resources.
@property int width;

/// Total height-wise count of pixels of the video frame. It must be greater or equal to 180 and less or equal to 1080. Values greater than 720 and aspect ratios other than 16:9 or 4:3 might be adjusted by the SDK consuming extra resources.
@property int height;

/// Informs how the content of the video frame is encoded.
@property ACSPixelFormat pixelFormat;

/// Informs how video frames will be available for encoding or decoding.
@property ACSVideoFrameKind videoFrameKind;

/// Informs how many frames per second the virtual video device will be sending to remote participants. It must be greater or equal to 1 and lower or equal to 30. The following values are preferable 7.5, 15 or 30.
@property float framesPerSecond;

/// Informs the stride in bytes for the first plane of the video frame content when VideoFrameKind is VideoSoftware. It must be greater or equal to the count of bytes required for the first plane of the selected PixelFormat.
@property int stride1;

/// For VideoFormats with more than one plane, informs the stride in bytes for the second plane of the video frame content when VideoFrameKind is VideoSoftware. It must be greater or equal to the count of bytes required for the second plane of the selected PixelFormat.
@property int stride2;

/// For VideoFormats with more than two planes, informs the stride in bytes for the third plane of the video frame content when VideoFrameKind is VideoSoftware. It must be greater or equal to the count of bytes required for the third plane of the selected PixelFormat.
@property int stride3;

@end

/// Contains information about changes to the flow control of a video or audio virtual device.
NS_SWIFT_NAME(VideoFrameSenderChangedEventArgs)
@interface ACSVideoFrameSenderChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Returns the VideoFrameSender object to be used to send video frames to remote participants.
@property (retain, nonnull, readonly) ACSVideoFrameSender * videoFrameSender;

@end

/// Abstract base class of video frame senders.
NS_SWIFT_NAME(VideoFrameSender)
@interface ACSVideoFrameSender : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Returns a timestamp of the current time and might be used while sending frames. This timestamp's time scale is in 100 of ns. Platform's time provider mechanism might also be used for sending frames as long as the value is in a scale of 100 of ns. The delivery of frames are not reordered based on timestamp. It throws an exception if running state is not started.
@property (readonly) int64_t timestampInTicks;

/// Returns the characteristics of how the video frame must be produced. It throws an exception if running state is not started.
@property (retain, nonnull, readonly) ACSVideoFormat * videoFormat;

/// Informs application on how to cast this object into an audio, video, software or hardware based frame class. It throws an exception if running state is not started.
@property (readonly) ACSVideoFrameKind videoFrameKind;

@end

/// Defines the options required for creating a virtual video device. Changes to RawOutgoingVideoStreamOptions do not affect previously created virtual video devices.
NS_SWIFT_NAME(RawOutgoingVideoStreamOptions)
@interface ACSRawOutgoingVideoStreamOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

@property (copy, nonnull) NSArray<ACSVideoFormat *> * videoFormats;

/**
 * The delegate that will handle events from the ACSRawOutgoingVideoStreamOptions.
 */
@property(nonatomic, weak, nullable) id<ACSRawOutgoingVideoStreamOptionsDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSRawOutgoingVideoStreamOptions.
 */
@property(nonatomic, strong, nonnull, readonly) ACSRawOutgoingVideoStreamOptionsEvents *events;

@end

/// FrameConfirmation holds information about media frames sent.
NS_SWIFT_NAME(FrameConfirmation)
@interface ACSFrameConfirmation : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Timestamp of when frame has been handed over to the encoder.
@property (readonly) int64_t timestampInTicks;

/// Information code reporting frame confirmation. 0 means frame has been confirmed.
@property (readonly) int status;

@end

/// SoftwareBasedVideoFrameSender allows the application to send a video frame to remote participants using a software based encoder. Any instance of this class should be discarded when virtual device running turns into stopped state. It is required that at least one of the supported video frames be a software based one. This is to allow fall backs when hardware based encoders are not available or overall conditions favor software based instead of hardware based.
NS_SWIFT_NAME(SoftwareBasedVideoFrameSender)
@interface ACSSoftwareBasedVideoFrameSender : ACSVideoFrameSender
-(nonnull instancetype)init NS_UNAVAILABLE;
// Class extension begins for SoftwareBasedVideoFrameSender.
/// Sends a video frame to remote participants. 
/// - important: The number of planes and pixel format has to match the video 
///              format provided to the sender, otherwise it is undefined behaviour. See `ACSVideoFormat`.
/// This method must be called while virtual device is in running. The asynchronous operation must be finalized before sending another frame. 
/// It throws an exception if running state is not started.
-(void)sendFrame:(CVImageBufferRef _Nonnull)frame timestampInTicks:(long long)timestamp withCompletionHandler:(void (^ _Nonnull )(ACSFrameConfirmation * _Nullable  value, NSError * _Nullable error))completionHandler NS_SWIFT_NAME(send(frame:timestampInTicks:completion:));
// Class extension ends for SoftwareBasedVideoFrameSender.

@end

/// Contains information about common properties between different types of outgoing virtual video streams
NS_SWIFT_NAME(RawOutgoingVideoStream)
@interface ACSRawOutgoingVideoStream : ACSOutgoingVideoStream
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Timestamp with the time of the current outgoing stream
@property (readonly) int64_t timestampInTicks;

@end

/// Screen Share stream information
NS_SWIFT_NAME(ScreenShareRawOutgoingVideoStream)
@interface ACSScreenShareRawOutgoingVideoStream : ACSRawOutgoingVideoStream
-(nonnull instancetype)init:(ACSRawOutgoingVideoStreamOptions * _Nonnull )videoStreamOptions NS_SWIFT_NAME( init(videoStreamOptions:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/**
 * The delegate that will handle events from the ACSScreenShareRawOutgoingVideoStream.
 */
@property(nonatomic, weak, nullable) id<ACSScreenShareRawOutgoingVideoStreamDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSScreenShareRawOutgoingVideoStream.
 */
@property(nonatomic, strong, nonnull, readonly) ACSScreenShareRawOutgoingVideoStreamEvents *events;

@end

/// Virtual stream information
NS_SWIFT_NAME(VirtualRawOutgoingVideoStream)
@interface ACSVirtualRawOutgoingVideoStream : ACSRawOutgoingVideoStream
-(nonnull instancetype)init:(ACSRawOutgoingVideoStreamOptions * _Nonnull )videoStreamOptions NS_SWIFT_NAME( init(videoStreamOptions:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/**
 * The delegate that will handle events from the ACSVirtualRawOutgoingVideoStream.
 */
@property(nonatomic, weak, nullable) id<ACSVirtualRawOutgoingVideoStreamDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSVirtualRawOutgoingVideoStream.
 */
@property(nonatomic, strong, nonnull, readonly) ACSVirtualRawOutgoingVideoStreamEvents *events;

@end

/// Options for joining a call using Room ID locator
NS_SWIFT_NAME(RoomCallLocator)
@interface ACSRoomCallLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSString * _Nonnull )roomId NS_SWIFT_NAME( init(roomId:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The Room identifier of the meeting
@property (retain, nonnull, readonly) NSString * roomId;

@end

NS_SWIFT_NAME(LocalAudioStream)
@interface ACSLocalAudioStream : ACSOutgoingAudioStream
-(nonnull instancetype)init;

@end

NS_SWIFT_NAME(RemoteAudioStream)
@interface ACSRemoteAudioStream : ACSIncomingAudioStream
-(nonnull instancetype)init;

@end

/// Wraps the diagnostic feature in the call context.
NS_SWIFT_NAME(DiagnosticsCallFeature)
@interface ACSDiagnosticsCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Source for all network diagnostics.
@property (retain, nonnull, readonly) ACSNetworkDiagnostics * networkDiagnostics;

/// Source for all media diagnostics.
@property (retain, nonnull, readonly) ACSMediaDiagnostics * mediaDiagnostics;

@end

/// Represents an object where network diagnostics are accessed.
NS_SWIFT_NAME(NetworkDiagnostics)
@interface ACSNetworkDiagnostics : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get latest values for all known network diagnostics.
@property (retain, nonnull, readonly) ACSNetworkDiagnosticValues * latest;

/**
 * The delegate that will handle events from the ACSNetworkDiagnostics.
 */
@property(nonatomic, weak, nullable) id<ACSNetworkDiagnosticsDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSNetworkDiagnostics.
 */
@property(nonatomic, strong, nonnull, readonly) ACSNetworkDiagnosticsEvents *events;

@end

/// Represents an object where all the latest diagnostics values for network diagnostic.
NS_SWIFT_NAME(NetworkDiagnosticValues)
@interface ACSNetworkDiagnosticValues : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

// Class extension begins for NetworkDiagnosticValues.
-(BOOL)valueForNoNetwork:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForNetworkRelaysNotReachable:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;

-(ACSDiagnosticQuality)valueForNetworkReconnect NS_REFINED_FOR_SWIFT;
-(ACSDiagnosticQuality)valueForNetworkReceiveQuality NS_REFINED_FOR_SWIFT;
-(ACSDiagnosticQuality)valueForNetworkSendQuality NS_REFINED_FOR_SWIFT;
// Class extension ends for NetworkDiagnosticValues.

@end

/// Event payload containing information of a boolean diagnostic change event.
NS_SWIFT_NAME(FlagDiagnosticChangedEventArgs)
@interface ACSFlagDiagnosticChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The new diagnostic value.
@property (readonly) BOOL value;

@end

/// Event payload containing information of a quality diagnostic change event.
NS_SWIFT_NAME(QualityDiagnosticChangedEventArgs)
@interface ACSQualityDiagnosticChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The new diagnostic quality value.
@property (readonly) ACSDiagnosticQuality value;

@end

/// Represents an object where media diagnostics are accessed.
NS_SWIFT_NAME(MediaDiagnostics)
@interface ACSMediaDiagnostics : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Stored latest values for all known media diagnostics.
@property (retain, nonnull, readonly) ACSMediaDiagnosticValues * latest;

/**
 * The delegate that will handle events from the ACSMediaDiagnostics.
 */
@property(nonatomic, weak, nullable) id<ACSMediaDiagnosticsDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSMediaDiagnostics.
 */
@property(nonatomic, strong, nonnull, readonly) ACSMediaDiagnosticsEvents *events;

@end

/// Represents an object where all the latest diagnostics values for media diagnostic.
NS_SWIFT_NAME(MediaDiagnosticValues)
@interface ACSMediaDiagnosticValues : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

// Class extension begins for MediaDiagnosticValues.
-(BOOL)valueForSpeakerNotFunctioning:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForSpeakerNotFunctioningDeviceInUse:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForSpeakerMuted:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForSpeakerVolumeIsZero:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForNoSpeakerDevicesEnumerated:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForSpeakingWhileMicrophoneIsMuted:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForNoMicrophoneDevicesEnumerated:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForMicrophoneNotFunctioningDeviceInUse:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForCameraFreeze:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForCameraStartFailed:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForCameraStartTimedOut:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForMicrophoneNotFunctioning:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForMicrophoneMuteUnexpectedly:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
-(BOOL)valueForCameraPermissionDenied:(NSError *_Nullable *_Nullable)error __attribute__((swift_error(nonnull_error))) NS_REFINED_FOR_SWIFT;
// Class extension ends for MediaDiagnosticValues.

@end

