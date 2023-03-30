//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
import ReplayKit
import CoreLocation
import PIPKit

class CallingSDKWrapper: NSObject, CallingSDKWrapperProtocol, CLLocationManagerDelegate{
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: Logger
    private let callConfiguration: CallConfiguration
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var localVideoStream: AzureCommunicationCalling.LocalVideoStream?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfo) -> Void)?
    
    /*
     * SCREEN SHARING
     */
    var videoFrmts: [VideoFormat] = []
    let videoFormat = VideoFormat()
    var screenShareRawOutgoingVideoStream: ScreenShareRawOutgoingVideoStream?
    var outgoingVideoStreamState: OutgoingVideoStreamState = .none
    var frameSender: VideoFrameSender?
    var locationManager: CLLocationManager?



    init(logger: Logger,
         callingEventsHandler: CallingSDKEventsHandling,
         callConfiguration: CallConfiguration) {
        self.logger = logger
        self.callingEventsHandler = callingEventsHandler
        self.callConfiguration = callConfiguration
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func setupCall() async throws {
        try await setupCallClientAndDeviceManager()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug("Reset Subjects in callingEventsHandler")
        if let callingEventsHandler = self.callingEventsHandler
            as? CallingSDKEventsHandler {
            callingEventsHandler.setupProperties()
        }
        logger.debug( "Starting call")
        do {
            try await setupCallAgent()
        } catch {
            throw CallCompositeInternalError.callJoinFailed
        }
        try await joinCall(isCameraPreferred: isCameraPreferred, isAudioPreferred: isAudioPreferred)
    }

    func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        logger.debug( "Joining call")
        let joinCallOptions = JoinCallOptions()

        if isCameraPreferred,
           let localVideoStream = localVideoStream {
            let localVideoStreamArray = [localVideoStream]
            let videoOptions = VideoOptions(localVideoStreams: localVideoStreamArray)
            joinCallOptions.videoOptions = videoOptions
        }

        joinCallOptions.audioOptions = AudioOptions()
        joinCallOptions.audioOptions?.muted = !isAudioPreferred

        var joinLocator: JoinMeetingLocator
        if callConfiguration.compositeCallType == .groupCall,
           let groupId = callConfiguration.groupId {
            joinLocator = GroupCallLocator(groupId: groupId)
        } else if let meetingLink = callConfiguration.meetingLink {
            joinLocator = TeamsMeetingLinkLocator(meetingLink: meetingLink)
        } else {
            logger.error("Invalid groupID / meeting link")
            throw CallCompositeInternalError.callJoinFailed
        }

        let joinedCall = try await callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions)

        guard let joinedCall = joinedCall else {
            logger.error( "Join call failed")
            throw CallCompositeInternalError.callJoinFailed
        }

        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            joinedCall.delegate = callingEventsHandler
        }
        call = joinedCall
        setupCallRecordingAndTranscriptionFeature()
    }
    
    

    func endCall() async throws {
        guard call != nil else {
            throw CallCompositeInternalError.callEndFailed
        }
        do {
            try await call?.hangUp(options: HangUpOptions())
            logger.debug("Call ended successfully")
        } catch {
            logger.error( "It was not possible to hangup the call.")
            throw error
        }
    }

    func getRemoteParticipant<ParticipantType, StreamType>(_ identifier: String)
    -> CompositeRemoteParticipant<ParticipantType, StreamType>? {
        guard let remote = findParticipant(identifier: identifier) else {
            return nil
        }

        let remoteParticipant = AzureCommunicationCalling.RemoteParticipant
            .toCompositeRemoteParticipant(acsRemoteParticipant: remote)
        guard let castValue = remoteParticipant as? CompositeRemoteParticipant<ParticipantType, StreamType> else {
            return nil
        }
        return castValue
    }

    func communicationIdForParticipant(identifier: String) -> CommunicationIdentifier? {
        findParticipant(identifier: identifier)?.identifier
    }

    private func findParticipant(identifier: String) -> AzureCommunicationCalling.RemoteParticipant? {
        call?.remoteParticipants.first(where: { $0.identifier.stringValue == identifier })
    }

    func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String)
    -> CompositeLocalVideoStream<LocalVideoStreamType>? {

        guard getLocalVideoStreamIdentifier() == identifier else {
            return nil
        }
        guard let videoStream = localVideoStream,
              let castVideoStream = videoStream as? LocalVideoStreamType else {
            return nil
        }
        guard videoStream is LocalVideoStreamType else {
            return nil
        }
        return CompositeLocalVideoStream(
            mediaStreamType: videoStream.mediaStreamType.asCompositeMediaStreamType,
            wrappedObject: castVideoStream
        )
    }

    func startCallLocalVideoStream() async throws -> String {
        let stream = await getValidLocalVideoStream()
        return try await startCallVideoStream(stream)
    }

    func stopLocalVideoStream() async throws {
        guard let call = self.call,
              let videoStream = self.localVideoStream else {
            logger.debug("Local video stopped successfully without call")
            return
        }
        do {
            try await call.stopVideo(stream: videoStream)
            logger.debug("Local video stopped successfully")
        } catch {
            logger.error( "Local video failed to stop. \(error)")
            throw error
        }
    }

    func switchCamera() async throws -> CameraDevice {
        guard let videoStream = localVideoStream else {
            let error = CallCompositeInternalError.cameraSwitchFailed
            logger.error("\(error)")
            throw error
        }
        let currentCamera = videoStream.source
        let flippedFacing: CameraFacing = currentCamera.cameraFacing == .front ? .back : .front

        let deviceInfo = await getVideoDeviceInfo(flippedFacing)
        try await change(videoStream, source: deviceInfo)
        return flippedFacing.toCameraDevice()
    }

    func startPreviewVideoStream() async throws -> String {
        _ = await getValidLocalVideoStream()
        return getLocalVideoStreamIdentifier() ?? ""
    }

    func muteLocalMic() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.mute()
        } catch {
            logger.error("ERROR: It was not possible to mute. \(error)")
            throw error
        }
        logger.debug("Mute successful")
    }

    func unmuteLocalMic() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.unmute()
        } catch {
            logger.error("ERROR: It was not possible to unmute. \(error)")
            throw error
        }
        logger.debug("Unmute successful")
    }

    func holdCall() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.hold()
            logger.debug("Hold Call successful")
        } catch {
            logger.error("ERROR: It was not possible to hold call. \(error)")
        }
    }

    func resumeCall() async throws {
        guard let call = call else {
            return
        }

        do {
            try await call.resume()
            logger.debug("Resume Call successful")
        } catch {
            logger.error( "ERROR: It was not possible to resume call. \(error)")
            throw error
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    
    func startScreenShare() async throws {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()

        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {response in
            if response{
                self.toggleSendingScreenShareOutgoingVideo()
            }
            else{
                //Access denied
            }
        })
    }
    
    var screenShareProducer: ScreenSharingProducer?
    var outgoingVideoSender: RawOutgoingVideoSender?
    var sendingScreenShare: Bool = false
    
    func toggleSendingScreenShareOutgoingVideo() {
        guard let call = call else {
            return
        }

        if sendingScreenShare {
            screenShareProducer?.stopRecording()
            outgoingVideoSender?.stopSending()
            outgoingVideoSender = nil
            screenShareProducer = nil
        } else {
            self.screenShareProducer = ScreenSharingProducer()
            self.screenShareProducer?.onReadyCallback = { [weak self] in
                guard let producer = self?.screenShareProducer else { return }
                
                self?.outgoingVideoSender = RawOutgoingVideoSender(frameProducer: producer)
                self?.outgoingVideoSender?.startSending(to: call)
            }
            screenShareProducer?.startRecording()
            DispatchQueue.main.async {
                PIPKit.visibleViewController?.startPIPMode()
            }
        }
        sendingScreenShare.toggle()
    }
    
    func stopScreenShare() async throws {
        print("stopScreenShare -- test")
        screenShareProducer?.stopRecording()
        screenShareProducer = nil
        outgoingVideoSender?.stopSending()
        outgoingVideoSender = nil
        sendingScreenShare.toggle()
        DispatchQueue.main.async {
            PIPKit.visibleViewController?.stopPIPMode()
        }
    }
}

// Produces random gray stripes.
final class GrayLinesFrameProducer: FrameProducerProtocol {
    var buffer: CVPixelBuffer? = nil
    private var currentFormat: VideoFormat?

    func nextFrame(for format: VideoFormat) -> CVImageBuffer {
        let bandsCount = Int.random(in: 10..<25)
        let bandThickness = Int(format.height * format.width) / bandsCount

        let currentFormat = self.currentFormat ?? format
        let bufferSizeChanged = currentFormat.width != format.width ||
                             currentFormat.height != format.height ||
                             currentFormat.stride1 != format.stride1

        let newBuffer = buffer == nil || bufferSizeChanged
        if newBuffer {
            // Make ARC release previous reusable buffer
            self.buffer = nil
            let attrs = [
                kCVPixelBufferBytesPerRowAlignmentKey: Int(format.stride1)
            ] as CFDictionary
            guard CVPixelBufferCreate(kCFAllocatorDefault, Int(format.width), Int(format.height),
                                      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, attrs, &buffer) == kCVReturnSuccess else {
                fatalError()
            }
        }

        self.currentFormat = format
        guard let frameBuffer = buffer else {
            fatalError()
        }

        CVPixelBufferLockBaseAddress(frameBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(frameBuffer, .readOnly)
        }

        // Fill NV12 Y plane with different luminance for each band.
        var begin = 0
        guard let yPlane = CVPixelBufferGetBaseAddressOfPlane(frameBuffer, 0) else {
            fatalError()
        }
        for _ in 0..<bandsCount {
            let luminance = Int32.random(in: 100..<255)
            memset(yPlane + begin, luminance, bandThickness)
            begin += bandThickness
        }

        if newBuffer {
            guard let uvPlane = CVPixelBufferGetBaseAddressOfPlane(frameBuffer, 1) else {
                fatalError()
            }
            memset(uvPlane, 128, Int((format.height * format.width) / 2))
        }

        return frameBuffer
    }
}

/*
 SCREEN SHARE
 */
protocol FrameProducerProtocol {
    func nextFrame(for format: VideoFormat) -> CVImageBuffer
}

extension CallingSDKWrapper {
    private func setupCallClientAndDeviceManager() async throws {
        do {
            let client = makeCallClient()
            callClient = client
            let deviceManager = try await client.getDeviceManager()
            deviceManager.delegate = self
            self.deviceManager = deviceManager
        } catch {
            throw CallCompositeInternalError.deviceManagerFailed(error)
        }
    }

    private func setupCallAgent() async throws {
        guard callAgent == nil else {
            logger.debug("Reusing call agent")
            return
        }

        let options = CallAgentOptions()
        if let displayName = callConfiguration.displayName {
            options.displayName = displayName
        }
        do {
            let callAgent = try await callClient?.createCallAgent(
                userCredential: callConfiguration.credential,
                options: options
            )
            self.logger.debug("Call agent successfully created.")
            self.callAgent = callAgent
        } catch {
            logger.error("It was not possible to create a call agent.")
            throw error
        }
    }

    private func makeCallClient() -> CallClient {
        let clientOptions = CallClientOptions()
        let appendingTag = self.callConfiguration.diagnosticConfig.tags
        let diagnostics = clientOptions.diagnostics ?? CallDiagnosticsOptions()
        diagnostics.tags.append(contentsOf: appendingTag)
        clientOptions.diagnostics = diagnostics
        
        
        
        return CallClient(options: clientOptions)
    }

    private func startCallVideoStream(
        _ videoStream: AzureCommunicationCalling.LocalVideoStream
    ) async throws -> String {
        guard let call = self.call else {
            let error = CallCompositeInternalError.cameraOnFailed
            self.logger.error( "Start call video stream failed")
            throw error
        }
        do {
            let localVideoStreamId = getLocalVideoStreamIdentifier() ?? ""
            try await call.startVideo(stream: videoStream)
            logger.debug("Local video started successfully")
            return localVideoStreamId
        } catch {
            logger.error( "Local video failed to start. \(error)")
            throw error
        }
    }

    private func change(
        _ videoStream: AzureCommunicationCalling.LocalVideoStream, source: VideoDeviceInfo
    ) async throws {
        do {
            try await videoStream.switchSource(camera: source)
            logger.debug("Local video switched camera successfully")
        } catch {
            logger.error( "Local video failed to switch camera. \(error)")
            throw error
        }
    }

    private func setupCallRecordingAndTranscriptionFeature() {
        guard let call = call else {
            return
        }
        let recordingCallFeature = call.feature(Features.recording)
        let transcriptionCallFeature = call.feature(Features.transcription)
        if let callingEventsHandler = self.callingEventsHandler as? CallingSDKEventsHandler {
            callingEventsHandler.assign(recordingCallFeature)
            callingEventsHandler.assign(transcriptionCallFeature)
        }
    }

    private func getLocalVideoStreamIdentifier() -> String? {
        guard localVideoStream != nil else {
            return nil
        }
        return "builtinCameraVideoStream"
    }
}

extension CallingSDKWrapper: DeviceManagerDelegate {
    func deviceManager(_ deviceManager: DeviceManager, didUpdateCameras args: VideoDevicesUpdatedEventArgs) {
        for newDevice in args.addedVideoDevices {
            newVideoDeviceAddedHandler?(newDevice)
        }
    }

    private func getVideoDeviceInfo(_ cameraFacing: CameraFacing) async -> VideoDeviceInfo {
        // If we have a camera, return the value right away
        await withCheckedContinuation({ continuation in
            if let camera = deviceManager?.cameras
                .first(where: { $0.cameraFacing == cameraFacing }
                ) {
                newVideoDeviceAddedHandler = nil
                return continuation.resume(returning: camera)
            }
            newVideoDeviceAddedHandler = { deviceInfo in
                if deviceInfo.cameraFacing == cameraFacing {
                    continuation.resume(returning: deviceInfo)
                }
            }
        })
    }

    private func getValidLocalVideoStream() async -> AzureCommunicationCalling.LocalVideoStream {
        if let existingVideoStream = localVideoStream {
            return existingVideoStream
        }

        let videoDevice = await getVideoDeviceInfo(.front)
        let videoStream = AzureCommunicationCalling.LocalVideoStream(camera: videoDevice)
        localVideoStream = videoStream
        return videoStream
    }
}

final class RawOutgoingVideoSender: NSObject {
    var frameSender: VideoFrameSender?
    let frameProducer: FrameProducerProtocol
    var rawOutgoingStream: RawOutgoingVideoStream!

    private var lock: NSRecursiveLock = NSRecursiveLock()

    private var timer: Timer?
    private var syncSema : DispatchSemaphore?
    private(set) weak var call: Call?
    private var running: Bool = false
    private let frameQueue: DispatchQueue = DispatchQueue(label: "com.citiacs.calling-screenshare")

    private var options: RawOutgoingVideoStreamOptions!
    private var outgoingVideoStreamState: OutgoingVideoStreamState = .none

    init(frameProducer: FrameProducerProtocol) {
        self.frameProducer = frameProducer
        super.init()

        let videoFormat = VideoFormat()
        
        print(UIScreen.main.nativeBounds.width.self)
        print(UIScreen.main.nativeBounds.height.self)
        videoFormat.width = 890
        videoFormat.height = 1900
        videoFormat.pixelFormat = .nv12
        videoFormat.videoFrameKind = .videoSoftware
        videoFormat.framesPerSecond = 30
        videoFormat.stride1 = 890
        videoFormat.stride2 = 890
        
        options = RawOutgoingVideoStreamOptions()
        options.videoFormats = [videoFormat]
        options.delegate = self


        self.rawOutgoingStream = ScreenShareRawOutgoingVideoStream(videoStreamOptions: options)
    }

    func startSending(to call: Call?) {
        self.call = call
        self.startRunning()
        self.call?.startVideo(stream: self.rawOutgoingStream) { error in
            // Stream sending started.
        }
    }

    func stopSending() {
        self.stopRunning()
        call?.stopVideo(stream: self.rawOutgoingStream) { error in
            // Stream sending stopped.
        }
    }

    private func startRunning() {
        lock.lock(); defer { lock.unlock() }

        self.running = true
        if frameSender != nil {
            self.startFrameGenerator()
        }
    }

    private func startFrameGenerator() {
        guard let sender = self.frameSender else {
            return
        }
        // How many times per second, based on sender format FPS.
        let interval = TimeInterval((1 as Float) / sender.videoFormat.framesPerSecond)
        frameQueue.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                guard let self = self, let sender = self.frameSender else {
                    return
                }
                let planeData = self.frameProducer.nextFrame(for: sender.videoFormat)
                self.sendSync(with: sender, frame: planeData)
            }
            RunLoop.current.run()
            self?.timer?.fire()
            
        }
    }

    private func sendSync(with sender: VideoFrameSender, frame: CVImageBuffer) {
        guard let softwareSender = sender as? SoftwareBasedVideoFrameSender else {
           return
        }
        // Ensure that a frame will not be sent before another finishes.
        syncSema = DispatchSemaphore(value: 0)
        softwareSender.send(frame: frame, timestampInTicks: sender.timestampInTicks) { [weak self] confirmation, error in
            self?.syncSema?.signal()
            guard let self = self else { return }
            if let confirmation = confirmation {
                print(confirmation.status)
                //Can check if confirmation was successful using `confirmation.status`
            } else if let error = error {
                //Can check details about error in case of failure.
            }
        }
        syncSema?.wait()
    }

    private func stopRunning() {
        lock.lock(); defer { lock.unlock() }

        running = false
        stopFrameGeneration()
    }

    private func stopFrameGeneration() {
        lock.lock(); defer { lock.unlock() }
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
}

extension RawOutgoingVideoSender: RawOutgoingVideoStreamOptionsDelegate {
    func rawOutgoingVideoStreamOptions(_ rawOutgoingVideoStreamOptions: RawOutgoingVideoStreamOptions,
                                       didChangeOutgoingVideoStreamState args: OutgoingVideoStreamStateChangedEventArgs) {
        outgoingVideoStreamState = args.outgoingVideoStreamState
    }

    func rawOutgoingVideoStreamOptions(_ rawOutgoingVideoStreamOptions: RawOutgoingVideoStreamOptions,
                                       didChangeVideoFrameSender args: VideoFrameSenderChangedEventArgs) {
        // Sender can change to start sending a more efficient format (given network conditions) of the ones specified
        // in the list on the initial step. In that case, you should restart the sender.
        if running {
            stopRunning()
            self.frameSender = args.videoFrameSender
            startRunning()
        } else {
            self.frameSender = args.videoFrameSender
        }
    }
}


extension CallingSDKWrapper: RPScreenRecorderDelegate{
    
}

final class ScreenSharingProducer: FrameProducerProtocol {
    private var sampleBuffer: CMSampleBuffer?
    let lock = NSRecursiveLock()
    
    //Gray
    var buffer: CVPixelBuffer? = nil
    private var currentFormat: VideoFormat?

    // Invoked when producer receives the first frame from ReplayKit.
    var onReadyCallback: (() -> Void)?

    // CMSSampleBuffer we get from ReplayKit produces Y and UV 4:2:0 planes data.
    func nextFrame(for format: VideoFormat) -> CVImageBuffer {
        lock.lock(); defer { lock.unlock() }
        guard let sampleBuffer = sampleBuffer, let frameBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError()
        }
        return frameBuffer
    }

    func startRecording() {
        // Start a recording of the screen with ReplayKit.
        let recorder = RPScreenRecorder.shared()
        if recorder.isAvailable {
            recorder.startCapture(handler: { [weak self] sampleBuffer, type, error in
                guard type == .video, error == nil else { return }
                guard let self = self else { return }
                self.lock.lock()
                let isFirstFrame = self.sampleBuffer == nil
                if isFirstFrame {
                    self.onReadyCallback?()
                    self.onReadyCallback = nil
                }
                self.sampleBuffer = sampleBuffer
                self.lock.unlock()
            }, completionHandler: { error in
                print(error)
            })
        }
    }

    func stopRecording() {
        guard RPScreenRecorder.shared().isRecording else {
            return
        }
        RPScreenRecorder.shared().stopCapture()
    }

    deinit {
        stopRecording()
    }
}
