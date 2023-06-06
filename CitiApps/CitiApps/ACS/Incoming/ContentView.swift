//
//  ContentView.swift
//  iOSVideo
//
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
import SwiftUI
import AzureCommunicationCommon
import AzureCommunicationCalling
import AVFoundation
import Foundation
import PushKit
import os.log
import CallKit

enum CreateCallAgentErrors: Error {
    case noToken
    case callKitInSDKNotSupported
}

struct ContentView: View {
    init(appPubs: AppPubs, callAgent:CallAgent) {
        self.appPubs = appPubs
        self.i_callAgent = callAgent
    }

    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ACSVideoSample")
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVFODQ4MjE0Qzc3MDczQUU1QzJCREU1Q0NENTQ0ODlEREYyQzRDODQiLCJ4NXQiOiJYb1NDRk1kd2M2NWNLOTVjelZSSW5kOHNUSVEiLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOmVhN2VlOWRiLTQxNDYtNGM2Yy04ZmZkLThiZmYzNWJkZDk4Nl8wMDAwMDAxOC01OWI3LTkwYmMtNjc2My01NjNhMGQwMDAzNDAiLCJzY3AiOjE3OTIsImNzaSI6IjE2ODQ3NDE2MzEiLCJleHAiOjE2ODQ4MjgwMzEsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiJlYTdlZTlkYi00MTQ2LTRjNmMtOGZmZC04YmZmMzViZGQ5ODYiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjg0NzQxNjMxfQ.fqg-gbrPYa88dMA3KkrUnqHBXikhoiT_cVFLj70_eCg6ylbvL5r4IldF5D7N3eyTcQhwiY-ZvAylXyEuYUFMyJRGzOhbh4gmYfvvtA8hQO0cJIiZQrouU9qozJbvH9L4tl7BppPvyEPRo7Vwi1P-hAgRCX21ULZggqyO1MAoCGBiEYAkVmq0nM5kSOGpnBLmmSyylif2bL7iQRM0IHatVWWP34HSsiuOfeznR3IrnpEn4dcJuZRyUh6L2P44pevqCQ-I9corStxOM8lex3pFsTGWzPXR8YGbiqwOjgg6wLUE2umJvUit-0wmxDdfo0yZwRK89Ak0qLNKdCQOyh5l2g"

    @State var callee: String = "8:acs:ea7ee9db-4146-4c6c-8ffd-8bff35bdd986_00000018-59b7-90bc-6763-563a0d000340"
    @State var callClient = CallClient()
    @State var callAgent: CallAgent?
    @State var call: Call?
    @State var deviceManager: DeviceManager?
    @State var localVideoStream = [LocalVideoStream]()
    @State var incomingCall: IncomingCall?
    @State var sendingVideo:Bool = false
    @State var errorMessage:String = "Unknown"

    @State var remoteVideoStreamData:[Int32:RemoteVideoStreamData] = [:]
    @State var previewRenderer:VideoStreamRenderer? = nil
    @State var previewView:RendererView? = nil
    @State var remoteRenderer:VideoStreamRenderer? = nil
    @State var remoteViews:[RendererView] = []
    @State var remoteParticipant: RemoteParticipant?
    @State var remoteVideoSize:String = "Unknown"
    @State var isIncomingCall:Bool = false
    @State var showAlert = false
    @State var alertMessage = ""
    @State var userDefaults: UserDefaults = .standard
    @State var isCallKitInSDKEnabled = false
    @State var isSpeakerOn:Bool = false
    @State var isMuted:Bool = false
    @State var isHeld: Bool = false
    
    @State var callState: String = "None"
    @State var incomingCallHandler: IncomingCallHandler?
    @State var cxProvider: CXProvider?
    @State var callObserver:CallObserver?
    @State var remoteParticipantObserver:RemoteParticipantObserver?
    @State var pushToken: Data?

    var appPubs: AppPubs
    var i_callAgent:CallAgent
    
    var containerView: some View {
        VStack{
            ZStack {
                ForEach(remoteViews, id:\.self) { renderer in
                    ZStack{
                        VStack{
                            RemoteVideoView(view: renderer)
                                .frame(width: .infinity, height: .infinity)
                                .background(Color(.white))
                        }
                        if(sendingVideo){
                            ZStack(alignment:.bottomTrailing){
                                VStack{
                                    PreviewVideoStream(view: previewView!)
                                        .frame(width: 135, height: 160)
                                        .background(Color(.white))
                                }.frame(maxWidth:.infinity, maxHeight:.infinity,alignment: .bottomTrailing)
                                    .clipShape(RoundedCornersShape(radius: 4, corners: [.allCorners]))
                                cameraSwitchButton
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    func switchCamera() {
        
    }

    func openChat() {
        var bankerEmailId = UserDefaults.standard.string(forKey: "loginUserName")
        var rootVc = UIApplication.shared.keyWindow?.rootViewController
        let chatController = ChatController(chatAdapter: nil, rootViewController: rootVc)
        chatController.bankerEmailId = bankerEmailId
        chatController.isForCall = false
        chatController.prepareChatComposite()
    }
    
    func shareScreen() {
        
    }
    var cameraSwitchButton : some View{
        Button(action: switchCamera) {
            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                .frame(width: 40, height: 40, alignment: .center)
        }
        .font(.system(size: 20))
        .disabled(call == nil)
        .foregroundColor(call == nil ? Color.gray : Color.white)
        .frame(width: 60, height: 60, alignment: .center)
        .background(Color.clear)
        .clipShape(RoundedCornersShape(radius: 4, corners: [.allCorners]))
    }
    
    func iconButton(iconName:String, action: @escaping (() -> Void)) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .frame(width: 40, height: 40, alignment: .center)
        }
        .font(.system(size: 18))
        .disabled(call == nil)
        .foregroundColor(call == nil ? Color.gray : Color.black)
        .frame(width: 60, height: 60, alignment: .center)
        .background(Color.white)
        .clipShape(RoundedCornersShape(radius: 4, corners: [.allCorners]))
    }
    
    var controlBarView : some View {
        Group{
            HStack{
                Group {
                    iconButton(iconName: isMuted ? "mic.slash.fill" : "mic.fill", action: switchMicrophone)
                    Spacer()
                    iconButton(iconName: sendingVideo ? "video.fill" : "video.slash.fill", action: toggleLocalVideo)
                    Spacer()
                    iconButton(iconName:"message.fill", action: openChat)
                    Spacer()
                    iconButton(iconName:"square.and.arrow.up.fill", action: shareScreen)
                    Spacer()
                    Button(action: endCall) {
                        Image(systemName: "phone.down.fill")
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    .font(.system(size: 18))
                    .disabled(call == nil)
                    .foregroundColor(call == nil ? Color.gray : Color.white)
                    .frame(width: 60, height: 60, alignment: .center)
                    .background(Color(red: 164/255, green: 46/255, blue: 67/255))
                    .clipShape(RoundedCornersShape(radius: 4, corners: [.allCorners]))
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
    
    var incomingCallBody: some View {
        ZStack{
            if (isIncomingCall) {
                VStack{
                    Spacer(minLength: 100)
                    Text("Incoming Call from...")
                        .font(.system(size: 20, weight: .bold))
                    Text("Janet Johnson")
                        .font(.system(size: 16))
                    HStack(alignment:.center, spacing: 50) {
                        Button(action: answerIncomingCall) {
                            HStack {
                                Text("Answer")
                                    .foregroundColor(.white)
                            }
                            .frame(width:80)
                            .padding(.vertical, 10)
                            .background(Color(.green))
                        }
                        Button(action: declineIncomingCall) {
                            HStack {
                                Text("Decline")
                                    .foregroundColor(.white)
                            }
                            .frame(width:80)
                            .padding(.vertical, 10)
                            .background(Color(.red))
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(10)
                    .background(Color.white)
                    Spacer()
                }
            }
            else{
                VStack(alignment: .center, spacing: 0){
                    containerView
                    controlBarView
                }
            }
        }
    }

    func exitAction() {
        
    }
    
    var body: some View {
        NavigationView {
            incomingCallBody
        }
        .onReceive(self.appPubs.$pushToken, perform: { newPushToken in
            guard let newPushToken = newPushToken else {
                print("Got empty token")
                return
            }

            if let existingToken = self.pushToken {
                if existingToken != newPushToken {
                    self.pushToken = newPushToken
                }
            } else {
                self.pushToken = newPushToken
            }
        })
        .onReceive(self.appPubs.$pushPayload, perform: { payload in
            handlePushNotification(payload)
        })
        .onAppear{
            self.callAgent = self.i_callAgent
            showIncomingCallBanner(globalIncomingCall)
            self.deviceManager = globalDeviceManager
            self.isCallKitInSDKEnabled = true
        }
    }

    func switchMicrophone() {
        guard let call = self.call else {
            return
        }

        if isCallKitInSDKEnabled {
            call.updateOutgoingAudio(mute: !isMuted) { error in
                if error == nil {
                    isMuted = !isMuted
                } else {
                    self.showAlert = true
                    self.alertMessage = "Failed to unmute/mute audio"
                }
            }
        } else {
            Task {
                await CallKitObjectManager.getCallKitHelper()!.muteCall(callId:call.id, isMuted: !isMuted) { error in
                    if error == nil {
                        isMuted = !isMuted
                    } else {
                        self.showAlert = true
                        self.alertMessage = "Failed to mute the call (without CallKit)"
                    }
                }
            }
        }
        
        userDefaults.set(isMuted, forKey: "isMuted")
    }

    func switchSpeaker() -> Void {
        let audioSession = AVAudioSession.sharedInstance()
        if isSpeakerOn {
            try! audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        } else {
            try! audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
        isSpeakerOn = !isSpeakerOn
        userDefaults.set(self.isSpeakerOn, forKey: "isSpeakerOn")
    }

    private func createCallAgentOptions() -> CallAgentOptions {
        let options = CallAgentOptions()
        options.callKitOptions = createCallKitOptions()
        return options
    }

    private func createCallKitOptions() -> CallKitOptions {
        let callKitOptions = CallKitOptions(with: CallKitObjectManager.createCXProvideConfiguration())
        callKitOptions.provideRemoteInfo = self.provideCallKitRemoteInfo
        return callKitOptions
    }
    
    func provideCallKitRemoteInfo(callerInfo: CallerInfo) -> CallKitRemoteInfo
    {
        let callKitRemoteInfo = CallKitRemoteInfo()
        callKitRemoteInfo.displayName = "Janet Johnson"
        callKitRemoteInfo.handle = CXHandle(type: .generic, value: "VALUE_TO_CXHANDLE")
        return callKitRemoteInfo
    }

    public func handlePushNotification(_ pushPayload: PKPushPayload?)
    {
        callAgent = globalCallAgent
        print("handlePushNotification")
        guard let pushPayload = pushPayload else {
            print("Got empty payload")
            return
        }

        if pushPayload.dictionaryPayload.isEmpty {
            os_log("ACS SDK got empty dictionary in push payload", log:self.log)
            return
        }

        let callNotification = PushNotificationInfo.fromDictionary(pushPayload.dictionaryPayload)

        let handlePush : (() -> Void) = {
            guard let callAgent = callAgent else {
                os_log("ACS SDK failed to create callAgent when handling push", log:self.log)
                self.showAlert = true
                self.alertMessage = "Failed to create CallAgent when handling push"
                return
            }

            // CallAgent is created normally handle the push
            callAgent.handlePush(notification: callNotification) { (error) in
                if error == nil {
                    os_log("SDK handle push notification normal mode: passed", log:self.log)
                } else {
                    os_log("SDK handle push notification normal mode: failed", log:self.log)
                }
            }
        }

        if self.callAgent == nil {
            createCallAgent { error in
                handlePush()
            }
        } else {
            handlePush()
        }
    }

    private func registerForPushNotification() {
        if let callAgent = self.callAgent,
           let pushToken = self.pushToken {
            callAgent.registerPushNotifications(deviceToken: pushToken) { error in
                if error != nil {
                    self.showAlert = true
                    self.alertMessage = "Failed to register for Push"
                }
                else{
                    print("Register for Push")
                }
            }
        }
    }

    private func createCallAgent(completionHandler: ((Error?) -> Void)?) {
        var userCredential: CommunicationTokenCredential
        do {
            userCredential = try CommunicationTokenCredential(token: token)
        } catch {
            self.showAlert = true
            self.alertMessage = "Failed to create CommunicationTokenCredential"
            completionHandler?(CreateCallAgentErrors.noToken)
            return
        }

        if callAgent != nil {
            // Have to dispose existing CallAgent if present
            // Because we cannot create two CallAgent's
            callAgent!.dispose()
            callAgent = nil
        }

        if userDefaults.value(forKey: "isCallKitInSDKEnabled") as? Bool ?? isCallKitInSDKEnabled {
            self.callClient.createCallAgent(userCredential: userCredential,
                                            options: createCallAgentOptions()) { (agent, error) in
                if error == nil {
                    CallKitObjectManager.deInitCallKitInApp()
                    self.callAgent = agent
                    self.cxProvider = nil
                    incomingCallHandler = IncomingCallHandler(contentView: self)
                    self.callAgent!.delegate = incomingCallHandler
                    registerForPushNotification()
                } else {
                    self.showAlert = true
                    self.alertMessage = "Failed to create CallAgent (with CallKit)"
                }
                completionHandler?(error)
            }
        } else {
            self.callClient.createCallAgent(userCredential: userCredential) { (agent, error) in
                if error == nil {
                    self.callAgent = agent
                    print("Call agent successfully created (without CallKit)")
                    incomingCallHandler = IncomingCallHandler(contentView: self)
                    self.callAgent!.delegate = incomingCallHandler
                    let _ = CallKitObjectManager.getOrCreateCXProvider()
                    CallKitObjectManager.getCXProviderImpl().setCallAgent(callAgent: callAgent!)
                    registerForPushNotification()
                } else {
                    self.showAlert = true
                    self.alertMessage = "Failed to create CallAgent (without CallKit)"
                }
                completionHandler?(error)
            }
        }
    }

    func declineIncomingCall() {
        guard let incomingCall = self.incomingCall else {
            self.showAlert = true
            self.alertMessage = "No incoming call to reject"
            return
        }

        incomingCall.reject { (error) in
            guard let rejectError = error else {
                return
            }
            self.showAlert = true
            self.alertMessage = rejectError.localizedDescription
            isIncomingCall = false
        }
    }

    func showIncomingCallBanner(_ incomingCall: IncomingCall?) {
        isIncomingCall = true
        self.incomingCall = incomingCall
    }

    func answerIncomingCall() {
        isIncomingCall = false
        let options = AcceptCallOptions()
        guard let incomingCall = self.incomingCall else {
            return
        }

        guard let deviceManager = deviceManager else {
            return
        }

        localVideoStream.removeAll()

        if(sendingVideo)
        {
            let camera = deviceManager.cameras.first
            localVideoStream.append(LocalVideoStream(camera: camera!))
            let videoOptions = VideoOptions(outgoingVideoStreams: localVideoStream)
            options.videoOptions = videoOptions
        }

        print("isCallKitInSDKEnabled")
        print(isCallKitInSDKEnabled)
        if isCallKitInSDKEnabled {
            print("incomingCall accept")
            incomingCall.accept(options: options) { (call, error) in
                print(call)
                print(error)
                setCallAndObersever(call: call, error: error)
            }
        } else {
            Task {
                await CallKitObjectManager.getCallKitHelper()!.acceptCall(callId: incomingCall.id,
                                                                           options: options) { call, error in
                    setCallAndObersever(call: call, error: error)
                }
            }
        }
    }

    func callRemoved(_ call: Call) {
        self.call = nil
        self.incomingCall = nil
        self.remoteRenderer?.dispose()
        for data in remoteVideoStreamData.values {
            data.renderer?.dispose()
        }
        self.previewRenderer?.dispose()
        sendingVideo = false
        Task {
            await CallKitObjectManager.getCallKitHelper()?.endCall(callId: call.id) { error in
            }
        }
    }

    private func createLocalVideoPreview() -> Bool {
        guard let deviceManager = self.deviceManager else {
            self.showAlert = true
            self.alertMessage = "No DeviceManager instance exists"
            return false
        }

        let scalingMode = ScalingMode.fit
        localVideoStream.removeAll()
        localVideoStream.append(LocalVideoStream(camera: deviceManager.cameras.first!))
        previewRenderer = try! VideoStreamRenderer(localVideoStream: localVideoStream.first!)
        previewView = try! previewRenderer!.createView(withOptions: CreateViewOptions(scalingMode:scalingMode))
        self.sendingVideo = true
        return true
    }

    func toggleLocalVideo() {
        guard let call = self.call else {
            if(!sendingVideo) {
                _ = createLocalVideoPreview()
            } else {
                self.sendingVideo = false
                self.previewView = nil
                self.previewRenderer!.dispose()
                self.previewRenderer = nil
            }
            return
        }

        if (sendingVideo) {
            call.stopVideo(stream: localVideoStream.first!) { (error) in
                if (error != nil) {
                    print("Cannot stop video")
                } else {
                    self.sendingVideo = false
                    self.previewView = nil
                    self.previewRenderer!.dispose()
                    self.previewRenderer = nil
                }
            }
        } else {
            if createLocalVideoPreview() {
                call.startVideo(stream:(localVideoStream.first)!) { (error) in
                    if (error != nil) {
                        print("Cannot send local video")
                    }
                }
            }
        }
    }

    func holdCall() {
        guard let call = self.call else {
            self.showAlert = true
            self.alertMessage = "No active call to hold/resume"
            return
        }
        
        if self.isHeld {
            if isCallKitInSDKEnabled {
                call.resume { error in
                    if error == nil {
                        self.isHeld = false
                    }  else {
                        self.showAlert = true
                        self.alertMessage = "Failed to hold the call"
                    }
                }
            } else {
                Task {
                    await CallKitObjectManager.getCallKitHelper()!.holdCall(callId: call.id, onHold: false) { error in
                        if error == nil {
                            self.isHeld = false
                        } else {
                            self.showAlert = true
                            self.alertMessage = "Failed to hold the call"
                        }
                    }
                }
            }
        } else {
            if isCallKitInSDKEnabled {
                call.hold { error in
                    if error == nil {
                        self.isHeld = true
                    } else {
                        self.showAlert = true
                        self.alertMessage = "Failed to resume the call"
                    }
                }
            } else {
                Task {
                    await CallKitObjectManager.getCallKitHelper()!.holdCall(callId: call.id, onHold: true) { error in
                        if error == nil {
                            self.isHeld = true
                        } else {
                            self.showAlert = true
                            self.alertMessage = "Failed to resume the call"
                        }
                    }
                }
            }
        }
    }

    func startCall() {
        let startCallOptions = StartCallOptions()
        if(sendingVideo)
        {
            guard let deviceManager = self.deviceManager else {
                self.showAlert = true
                self.alertMessage = "No DeviceManager instance exists"
                return
            }

            localVideoStream.removeAll()
            localVideoStream.append(LocalVideoStream(camera: deviceManager.cameras.first!))
            let videoOptions = VideoOptions(outgoingVideoStreams: localVideoStream)
            startCallOptions.videoOptions = videoOptions
        }
        let callees:[CommunicationIdentifier] = [CommunicationUserIdentifier(self.callee)]
        
        if self.isCallKitInSDKEnabled {
            guard let callAgent = self.callAgent else {
                self.showAlert = true
                self.alertMessage = "No CallAgent instance exists to place the call"
                return
            }

            callAgent.startCall(participants: callees, options: startCallOptions) { (call, error) in
                setCallAndObersever(call: call, error: error)
            }
        } else {
            Task {
                await CallKitObjectManager.getCallKitHelper()!.placeCall(participants: callees,
                                              callerDisplayName: "Alice",
                                              meetingLocator: nil,
                                              options: startCallOptions) { call, error in
                    setCallAndObersever(call: call, error: error)
                }
            }
        }
    }

    func setCallAndObersever(call:Call!, error:Error?) {
        if (error == nil) {
            self.call = call
            self.callObserver = CallObserver(self)
            self.call!.delegate = self.callObserver
            self.remoteParticipantObserver = RemoteParticipantObserver(self)
            switchSpeaker()
        } else {
            print("Failed to get call object")
        }
    }

    func endCall() {
        if self.isCallKitInSDKEnabled {
            self.call!.hangUp(options: HangUpOptions()) { (error) in
                if (error != nil) {
                    print("ERROR: It was not possible to hangup the call.")
                }
            }
        } else {
            Task {
                await CallKitObjectManager.getCallKitHelper()!.endCall(callId: self.call!.id) { error in
                    if (error != nil) {
                        print("ERROR: It was not possible to hangup the call.")
                    }
                }
            }
        }
        self.previewRenderer?.dispose()
        self.remoteRenderer?.dispose()
        sendingVideo = false
        isSpeakerOn = false
    }
}

public class RemoteVideoStreamData : NSObject, RendererDelegate {
    public func videoStreamRenderer(didFailToStart renderer: VideoStreamRenderer) {
        owner.errorMessage = "Renderer failed to start"
    }

    private var owner:ContentView
    let stream:RemoteVideoStream
    var renderer:VideoStreamRenderer? {
        didSet {
            if renderer != nil {
                renderer!.delegate = self
            }
        }
    }

    var views:[RendererView] = []
    init(view:ContentView, stream:RemoteVideoStream) {
        owner = view
        self.stream = stream
    }

    public func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer) {
        let size:StreamSize = renderer.size
        owner.remoteVideoSize = String(size.width) + " X " + String(size.height)
    }
}

public class CallObserver: NSObject, CallDelegate, IncomingCallDelegate {
    private var owner: ContentView
    private var callKitHelper: CallKitHelper?
    
    init(_ view:ContentView) {
        owner = view
    }

    public func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        switch call.state {
        case .connected:
            owner.callState = "Connected"
        case .connecting:
            owner.callState = "Connecting"
        case .disconnected:
            owner.callState = "Disconnected"
        case .disconnecting:
            owner.callState = "Disconnecting"
        case .inLobby:
            owner.callState = "InLobby"
        case .localHold:
            owner.callState = "LocalHold"
        case .remoteHold:
            owner.callState = "RemoteHold"
        case .ringing:
            owner.callState = "Ringing"
        case .earlyMedia:
            owner.callState = "EarlyMedia"
        case .none:
            owner.callState = "None"
        default:
            owner.callState = "Default"
        }

        if(call.state == CallState.connected) {
            initialCallParticipant()
        }
        
        if(call.state == CallState.disconnected) {
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.dismiss(animated: true)
        }

        Task {
            await CallKitObjectManager.getCallKitHelper()?.reportOutgoingCall(call: call)
        }
    }
    
    public func call(_ call: Call, didUpdateOutgoingAudioState args: PropertyChangedEventArgs) {
        owner.isMuted = call.isOutgoingAudioMuted
    }

    public func call(_ call: Call, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs) {
        for participant in args.addedParticipants {
            participant.delegate = owner.remoteParticipantObserver
            for stream in participant.videoStreams {
                if !owner.remoteVideoStreamData.isEmpty {
                    return
                }
                let data:RemoteVideoStreamData = RemoteVideoStreamData(view: owner, stream: stream)
                let scalingMode = ScalingMode.fit
                data.renderer = try! VideoStreamRenderer(remoteVideoStream: stream)
                let view:RendererView = try! data.renderer!.createView(withOptions: CreateViewOptions(scalingMode:scalingMode))
                data.views.append(view)
                self.owner.remoteViews.append(view)
                owner.remoteVideoStreamData[stream.id] = data
            }
            owner.remoteParticipant = participant
        }
    }

    public func initialCallParticipant() {
        for participant in owner.call!.remoteParticipants {
            participant.delegate = owner.remoteParticipantObserver
            for stream in participant.videoStreams {
                renderRemoteStream(stream)
            }
            owner.remoteParticipant = participant
        }
    }

    public func renderRemoteStream(_ stream: RemoteVideoStream!) {
        if !owner.remoteVideoStreamData.isEmpty {
            return
        }
        let data:RemoteVideoStreamData = RemoteVideoStreamData(view: owner, stream: stream)
        let scalingMode = ScalingMode.fit
        data.renderer = try! VideoStreamRenderer(remoteVideoStream: stream)
        let view:RendererView = try! data.renderer!.createView(withOptions: CreateViewOptions(scalingMode:scalingMode))
        self.owner.remoteViews.append(view)
        owner.remoteVideoStreamData[stream.id] = data
    }
}

public class RemoteParticipantObserver : NSObject, RemoteParticipantDelegate {
    private var owner:ContentView
    init(_ view:ContentView) {
        owner = view
    }

    public func renderRemoteStream(_ stream: RemoteVideoStream!) {
        let data:RemoteVideoStreamData = RemoteVideoStreamData(view: owner, stream: stream)
        let scalingMode = ScalingMode.fit
        do {
            data.renderer = try VideoStreamRenderer(remoteVideoStream: stream)
            let view:RendererView = try data.renderer!.createView(withOptions: CreateViewOptions(scalingMode:scalingMode))
            self.owner.remoteViews.append(view)
            owner.remoteVideoStreamData[stream.id] = data
        } catch let error as NSError {
            self.owner.alertMessage = error.localizedDescription
            self.owner.showAlert = true
        }
    }

    public func remoteParticipant(_ remoteParticipant: RemoteParticipant, didUpdateVideoStreams args: RemoteVideoStreamsEventArgs) {
        for stream in args.addedRemoteVideoStreams {
            renderRemoteStream(stream)
        }
        for _ in args.removedRemoteVideoStreams {
            for data in owner.remoteVideoStreamData.values {
                data.renderer?.dispose()
            }
            owner.remoteViews.removeAll()
        }
    }
}

struct PreviewVideoStream: UIViewRepresentable {
    let view:RendererView
    func makeUIView(context: Context) -> UIView {
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct RemoteVideoView: UIViewRepresentable {
    let view:RendererView
    func makeUIView(context: Context) -> UIView {
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct RoundedCornersShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
