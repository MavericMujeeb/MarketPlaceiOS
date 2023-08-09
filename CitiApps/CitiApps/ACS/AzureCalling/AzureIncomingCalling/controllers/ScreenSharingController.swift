//
//  IncomingCallViewModel.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 07/07/23.
//

import Foundation
import RealityKit
import AzureCommunicationCalling
import Combine
import ReplayKit
import PIPKit


class ScreenSharingController : NSObject, ObservableObject{
  
    var screenShareProducer: ScreenSharingProducer?
    var outgoingVideoSender: RawOutgoingVideoSender?
    var isSharingScreen : Bool = false
    
    func startScreenRecording (acsCall: Call) {
        self.screenShareProducer = ScreenSharingProducer()
        self.screenShareProducer?.onReadyCallback = { [weak self] in
            guard let producer = self?.screenShareProducer else { return }

            self?.outgoingVideoSender = RawOutgoingVideoSender(frameProducer: producer)
            self?.outgoingVideoSender?.startSending(to: acsCall)
        }
        self.screenShareProducer?.startRecording()
        
        DispatchQueue.main.async {
            PIPKit.visibleViewController?.startPIPMode()
        }
        isSharingScreen.toggle()
    }
    
    func stopPipMode(){
        DispatchQueue.main.async {
            PIPKit.visibleViewController?.stopPIPMode()
        }
    }
    
    func stopScreenRecording() {
        stopPipMode()
        if isSharingScreen {
            screenShareProducer?.stopRecording()
            outgoingVideoSender?.stopSending()
            outgoingVideoSender = nil
            screenShareProducer = nil
        }
        isSharingScreen.toggle()
    }
    
    func toggleSendingScreenShareOutgoingVideo(acsCall:Call?) {
        guard let call = acsCall else {
            return
        }
        
        if isSharingScreen {
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
//            DispatchQueue.main.async {
//                PIPKit.visibleViewController?.startPIPMode()
//            }
        }
        isSharingScreen.toggle()
    }
}


/*
 SCREEN SHARE
 */
protocol FrameProducerProtocol {
    func nextFrame(for format: VideoFormat) -> CVImageBuffer
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

