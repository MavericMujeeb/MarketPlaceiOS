//
//  IncomingCallView.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 03/07/23.
//

import SwiftUI
import FluentUI
import Combine
import AzureCommunicationCommon
import AzureCommunicationCalling
import AVFoundation
import Foundation
import PushKit
import os.log
import CallKit
import ReplayKit
import AzureCommunicationUICalling

enum CreateCallAgentErrors: Error {
    case noToken
    case callKitInSDKNotSupported
}

struct IncomingCallView: View {
    
    @StateObject var screenSharingController : ScreenSharingController = ScreenSharingController()
    
    init(appPubs: AppPubs) {
        self.appPubs = appPubs
    }
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ACSVideoSample")
    private let token = ""
    @State var callee: String = ""
    @State var callClient = CallClient()
    @State var callAgent: CallAgent?
    @State var call: Call?
    @State var deviceManager: DeviceManager?
    @State var localVideoStream = [LocalVideoStream]()
    @State var incomingCall: IncomingCall?
    @State var sendingVideo:Bool = false
    @State var errorMessage:String = "Unknown"
    @State var remoteVideoStreamData:[Int32:Remo
                                      teVideoStreamData] = [:]
    @State var previewRenderer:VideoStreamRenderer? = nil
    @State var previewView:RendererView? = nil
    @State var remoteRenderer:VideoStreamRenderer? = nil
    @State var remoteViews:[RendererView] = []
    @State var remoteParticipant: RemoteParticipant?
    @State var remoteVideoSize:String = "Unknown"
    @State var showAlert = false
    @State var alertMessage = ""
    @State var userDefaults: UserDefaults = .standard
    @State var isCallKitInSDKEnabled = false
    @State var isSpeakerOn:Bool = false
    @State var isMuted:Bool = false
    @State var isSharingScreen:Bool = false
    @State var isHeld: Bool = false
    @State var callState: String = "None"
    @State var incomingCallHandler: IncomingCallHandler?
    @State var cxProvider: CXProvider?
    @State var callObserver:CallObserver?
    @State var remoteParticipantObserver:RemoteParticipantObserver?
    @State var pushToken: Data?
    @State var callStatus: String = ""
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    @State var screenShareProducer: ScreenSharingProducer?
    @State var outgoingVideoSender: RawOutgoingVideoSender?
    
    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?
    var appPubs: AppPubs
    
    var body: some View{
        ZStack{
            VStack(spacing: 24){
                titleView
                if self.call != nil {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottomLeading) {
                            VStack( spacing: 24 ){
                                ZStack(alignment: .bottom){
                                    previewAreaView
                                    bottomControlBarView
                                }
                            }
                        }
                    }
                }
                else {
                    incomingCallBody
                }
            }
        }
        .onReceive(self.appPubs.$pushToken, perform: { newPushToken in
            guard let newPushToken = newPushToken else {
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
            if deviceManager == nil {
                self.callClient.getDeviceManager { (deviceManager, error) in
                    if(error == nil){
                        UIDevice.current.endGeneratingDeviceOrientationNotifications()
                        self.deviceManager = deviceManager
                    }
                }

            }
        }
    }
    
    var titleView: some View{
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                HStack {
                    Spacer()
                    VStack {
                        Text("Call")
                            .fontWeight(.medium)
                            .font(.system(size: 20))
                    }
                    Spacer()
                }.accessibilitySortPriority(1)
                 .padding(34)
            }.frame(height: 44)
                .background()
            Divider()
        }
    }
    
    var avatarView: some View {
        GeometryReader{ geometry in
            VStack(alignment: .center, spacing: 5) {
                AvatarIcon(displayName: ACSResources.bankerUserName,
                    isSpeaking: false,
                           avatarSize: .xxlarge)
                Spacer().frame(height: 10)
                participantTitleView
                
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
            .accessibilityElement(children: .combine)
        }
    }

    var participantTitleView: some View {
        HStack(alignment: .center, spacing: 4, content: {
            Image("video-off")
                .renderingMode(.template)
                .foregroundColor(.gray)
            Text(ACSResources.bankerUserName)
                .font(.system(size: 20))
                .lineLimit(1)
                .foregroundColor(Color(.gray))
            
        })
        .padding(.horizontal, 4)
        .animation(.default)
    }
    
    
    private func getSizeClass() -> ScreenSizeClassType {
        switch (widthSizeClass, heightSizeClass) {
        case (.compact, .regular):
            return .iphonePortraitScreenSize
        case (.compact, .compact),
             (.regular, .compact):
            return .iphoneLandscapeScreenSize
        default:
            return .ipadScreenSize
        }
    }
    
    var remoteVideoView: some View {
        ForEach(remoteViews, id:\.self) { renderer in
            ZStack{
                VStack{
                    RemoteVideoView(view: renderer)
                        .frame(width: .infinity, height: .infinity)
                        .background(Color(.white))
                }
            }
        }
    }

    var previewAreaView: some View{
        Group{
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing){
                    if remoteViews.count > 0 {
                        remoteVideoView
                    }
                    else{
                        avatarView
                    }
                    if sendingVideo {
                        if !isSharingScreen {
                            DraggableLocalVideoView(containerBounds:  geometry.frame(in: .local), previewView:previewView, orientation: $orientation, screenSize: getSizeClass())
                        }
                    }
                }
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
        }
    }
    
    
    func answerIncomingCall() {
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

        incomingCall.accept(options: options) { (call, error) in
            setCallAndObersever(call: call, error: error)
        }
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
    
    func switchMicrophone() {
        guard let call = self.call else {
            return
        }
        
        call.updateOutgoingAudio(mute: !isMuted) { error in
            if error == nil {
                isMuted = !isMuted
            } else {
                self.showAlert = true
                self.alertMessage = "Failed to unmute/mute audio"
            }
        }
        
        userDefaults.set(isMuted, forKey: "isMuted")
    }
    
    func openChat() {
        if(isSharingScreen){
            screenSharingController.stopScreenRecording()
        }
        let rootVc = UIApplication.shared.keyWindow?.rootViewController
        
        let chatController = AzureChatController(chatAdapter: nil, rootViewController: rootVc)
        chatController.bankerEmailId = ACSResources.bankerUserEmail
        chatController.isForCall = false
        
        chatController.prepareChatComposite()
    }
    
    func stopScreenShare () {
        //stop screen recording
        screenSharingController.stopScreenRecording()
        isSharingScreen.toggle()
        if(sendingVideo){
            //if previoustly streaming local video then resume local video
            createLocalVideoPreview()
        }
    }
    
    func toggleScreenShare () {
        guard let call = self.call else {
            return
        }
        //If screen is already presented : stop sharing the screenn
        if(isSharingScreen){
            stopScreenShare()
            return
        }
        
        if(sendingVideo) {
            call.stopVideo(stream: localVideoStream.first!) { (error) in
                if(error != nil) {
                    print("localvideo stream stopped")
                }
                else{
                    isSharingScreen = true
                    screenSharingController.startScreenRecording(acsCall: call)
                }
            }
        }
        else {
            isSharingScreen = true
            screenSharingController.startScreenRecording(acsCall: call)
        }
    }
    
    func endCall() {
        if isSharingScreen {
            screenSharingController.stopScreenRecording()
            isSharingScreen.toggle()
        }
        
        self.call!.hangUp(options: HangUpOptions()) { (error) in
            if (error != nil) {
                print("ERROR: It was not possible to hangup the call.")
            }
        }
        
        self.previewRenderer?.dispose()
        self.remoteRenderer?.dispose()
        
        sendingVideo = false
        isSpeakerOn = false
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
    
    
    var videoButton: some View {
        IconButton(buttonAction: toggleLocalVideo, iconName: sendingVideo ? "video-on" : "video-off", iconSize: 30, iconColor: .black)
    }
    
    var micButton: some View {
        IconButton(buttonAction: switchMicrophone, iconName: isMuted ? "mic-off" : "mic-on", iconSize: 30, iconColor: .black)
    }
    
    var chatButton: some View {
        IconButton(buttonAction: openChat, iconName: "chat-icon", iconSize: 30, iconColor: .black)
    }
    
    var screenShareButton: some View {
        IconButton(buttonAction: toggleScreenShare, iconName: isSharingScreen ? "screenshare_stop" : "screenshare_start", iconSize: 30, iconColor: .black)
    }
    
    var hangUpButton: some View {
        IconButton(buttonAction: endCall, iconName: "call-end", iconSize: 30, iconColor: .white)
    }
    

    var bottomControlBarView : some View {
        Group{
            HStack {
                videoButton
                Spacer()
                micButton
                Spacer()
                chatButton
                Spacer()
                screenShareButton
                Spacer()
                hangUpButton
                    .background(Color("hangup-color"))
                    .clipShape(RoundedCornersShape(radius: 8, corners: .allCorners))

            }
        }
        .padding(15)
        .background(Color("toolbar-color"))
    }
    
    public func handlePushNotification(_ pushPayload: PKPushPayload?)
    {
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
    
    func provideCallKitRemoteInfo(callerInfo: CallerInfo) -> CallKitRemoteInfo
    {
        //get banker display name
        let callKitRemoteInfo = CallKitRemoteInfo()
        callKitRemoteInfo.displayName = ACSResources.bankerUserName

        callKitRemoteInfo.handle = CXHandle(type: .generic, value: "VALUE_TO_CXHANDLE")
        return callKitRemoteInfo
    }
    
    
    private func createCallKitOptions() -> CallKitOptions {
        let callKitOptions = CallKitOptions(with: CallKitObjectManager.createCXProvideConfiguration())
        callKitOptions.provideRemoteInfo = self.provideCallKitRemoteInfo
        return callKitOptions
    }
    
    private func createCallAgentOptions() -> CallAgentOptions {
        let options = CallAgentOptions()
        options.callKitOptions = createCallKitOptions()
        return options
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
    
    func showIncomingCallBanner(_ incomingCall: IncomingCall?) {
        self.incomingCall = incomingCall
    }
    

    func callRemoved(_ call: Call) {
        print("call removed called")
        if callAgent != nil {
            // Have to dispose existing CallAgent if present
            // Because we cannot create two CallAgent's
            callAgent!.dispose()
            callAgent = nil
        }
        self.call = nil
        self.incomingCall = nil
        self.remoteRenderer?.dispose()
        for data in remoteVideoStreamData.values {
            data.renderer?.dispose()
        }
        self.previewRenderer?.dispose()
        sendingVideo = false
        Task {
            print("endCall -- callkit")
            await CallKitObjectManager.getCallKitHelper()?.endCall(callId: call.id) { error in
            }
        }
    }
    
    private func createCallAgent(completionHandler: ((Error?) -> Void)?) {
        print("inside createCallAgent")
        let acsToken =  self.userDefaults.value(forKey: StorageKeys.acsToken) as! String

        var userCredential: CommunicationTokenCredential
        do {
            userCredential = try CommunicationTokenCredential(token: acsToken)
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
                print("Failed to create CallAgent (with CallKit)")
                self.showAlert = true
                self.alertMessage = "Failed to create CallAgent (with CallKit)"
            }
            completionHandler?(error)
        }
    }
    
    
    var incomingCallBody: some View {
        VStack(alignment: .center){
            Spacer(minLength: 50)
            Text("Incoming Call from...")
                .font(.system(size: 20, weight: .bold))
            Text(ACSResources.bankerUserName)
                .font(.system(size: 16))
            HStack(alignment:.center, spacing: 50) {
                Button(action: answerIncomingCall) {
                    HStack {
                        Text("Answer")
                            .foregroundColor(.white)
                    }
                    .frame(width:80)
                    .padding(.vertical, 10)
                    .background(Color("accept-green"))
                    .clipShape(RoundedCornersShape(radius: 8, corners: .allCorners))
                }
                Button(action: declineIncomingCall) {
                    HStack {
                        Text("Decline")
                            .foregroundColor(.white)
                    }
                    .frame(width:80)
                    .padding(.vertical, 10)
                    .background(Color("hangup-color"))
                    .clipShape(RoundedCornersShape(radius: 8, corners: .allCorners))

                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(10)
            .background(Color.white)
            Spacer()
        }
    }
}

public class RemoteVideoStreamData : NSObject, RendererDelegate {
    public func videoStreamRenderer(didFailToStart renderer: VideoStreamRenderer) {
        owner.errorMessage = "Renderer failed to start"
    }

    private var owner:IncomingCallView
    let stream:RemoteVideoStream
    var renderer:VideoStreamRenderer? {
        didSet {
            if renderer != nil {
                renderer!.delegate = self
            }
        }
    }

    var views:[RendererView] = []
    init(view:IncomingCallView, stream:RemoteVideoStream) {
        owner = view
        self.stream = stream
    }

    public func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer) {
        let size:StreamSize = renderer.size
        owner.remoteVideoSize = String(size.width) + " X " + String(size.height)
    }
}

struct IconButton: View {
    
    var buttonAction: (() -> Void)
    var iconName: String
    var iconSize: CGFloat
    var iconColor: Color
    
    var body: some View{
        Group{
            Button(action: buttonAction) {
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: iconSize, height: iconSize, alignment: .center)
                    .contentShape(Rectangle())
                    .foregroundColor(iconColor)
            }
            .frame(width: 60, height: 60, alignment: .center)
            .clipShape(RoundedCornersShape(radius: 8, corners: .allCorners))
        }
        .frame(width: 60,
               height: 60,
               alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture(perform: buttonAction)
    }
}


struct AvatarIcon: View {
    var displayName: String?
    var avatarImage: UIImage?
    var isSpeaking: Bool
    var avatarSize: MSFAvatarSize = .xxlarge
    var body: some View {
        let isNameEmpty = displayName == nil
        || displayName?.trimmingCharacters(in: .whitespaces).isEmpty == true
        return Avatar(style: isNameEmpty ? .outlined : .default,
                      size: avatarSize,
                      image: avatarImage,
                      primaryText: displayName)
        .ringColor(UIColor(red: 255, green: 23, blue: 23, alpha: 1))
            .isRingVisible(isSpeaking)
            .accessibilityHidden(true)
    }
}

struct DraggableLocalVideoView: View {
    let containerBounds: CGRect
    
    @State var previewView:RendererView? = nil
    
    @State var pipPosition: CGPoint?
    @GestureState var pipDragStartPosition: CGPoint?
    @Binding var orientation: UIDeviceOrientation
    let screenSize: ScreenSizeClassType

    var body: some View {
        return GeometryReader { geometry in
            let size = getPipSize(parentSize: geometry.size)
            localVideoPipView
                .frame(width: size.width, height: size.height, alignment: .center)
                .position(self.pipPosition ?? getInitialPipPosition(containerBounds: containerBounds))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let containerBounds = getContainerBounds(bounds: geometry.frame(in: .local))
                            let translatedPipPosition = getTranslatedPipPosition(
                                currentPipPosition: self.pipPosition!,
                                pipDragStartPosition: self.pipDragStartPosition,
                                translation: value.translation,
                                isRightToLeft: true)
                            self.pipPosition = getBoundedPipPosition(
                                currentPipPosition: self.pipPosition!,
                                requestedPipPosition: translatedPipPosition,
                                bounds: containerBounds)
                        }
                        .updating($pipDragStartPosition) { (_, startLocation, _) in
                            startLocation = startLocation ?? self.pipPosition
                        }
                )
                .onAppear {
                    self.pipPosition = getInitialPipPosition(containerBounds: containerBounds)
                }
                .onChange(of: geometry.size) { _ in
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                }
                .onChange(of: orientation) { _ in
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                }
        }
    }

    var localVideoPipView: some View {
        let shapeCornerRadius: CGFloat = 20
        return Group {
            PreviewVideoStream(view: previewView!)
//            .background(Color("toolbar-color"))
            .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
        }
    }

    private func getInitialPipPosition(containerBounds: CGRect) -> CGPoint {
        return CGPoint(
            x: getContainerBounds(bounds: containerBounds).maxX,
            y: getContainerBounds(bounds: containerBounds).maxY)
    }

    private func getContainerBounds(bounds: CGRect) -> CGRect {
        let pipSize = getPipSize(parentSize: bounds.size)
        let containerBounds = bounds.inset(by: UIEdgeInsets(
            top: pipSize.height / 1.0 + 20,
            left: pipSize.width / 1.0 + 10,
            bottom: pipSize.height / 1.0 + 40,
            right: pipSize.width / 1.0 + 0))
        return containerBounds
    }

    private func getTranslatedPipPosition(
        currentPipPosition: CGPoint,
        pipDragStartPosition: CGPoint?,
        translation: CGSize,
        isRightToLeft: Bool) -> CGPoint {
            var translatedPipPosition = pipDragStartPosition ?? currentPipPosition
            translatedPipPosition.x += isRightToLeft
            ? -translation.width
            : translation.width
            translatedPipPosition.y += translation.height
            return translatedPipPosition
        }

    private func getBoundedPipPosition(
        currentPipPosition: CGPoint,
        requestedPipPosition: CGPoint,
        bounds: CGRect) -> CGPoint {
            var boundedPipPosition = currentPipPosition

            if bounds.contains(requestedPipPosition) {
                boundedPipPosition = requestedPipPosition
            } else if requestedPipPosition.x > bounds.minX && requestedPipPosition.x < bounds.maxX {
                boundedPipPosition.x = requestedPipPosition.x
                boundedPipPosition.y = getLimitedValue(
                    value: requestedPipPosition.y,
                    min: bounds.minY,
                    max: bounds.maxY)
            } else if requestedPipPosition.y > bounds.minY && requestedPipPosition.y < bounds.maxY {
                boundedPipPosition.x = getLimitedValue(
                    value: requestedPipPosition.x,
                    min: bounds.minX,
                    max: bounds.maxX)
                boundedPipPosition.y = requestedPipPosition.y
            }

            return boundedPipPosition
        }

    /// Gets the size of the Pip view based on the parent size
    /// - Parameter parentSize: size of the parent view
    /// - Returns: the size of the Pip view based on the parent size
    private func getPipSize(parentSize: CGSize? = nil) -> CGSize {
        let isPortraitMode = screenSize != .iphoneLandscapeScreenSize
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad

        func defaultPipSize() -> CGSize {
            let width = isPortraitMode ? 72 : 104
            let height = isPortraitMode ? 104 : 72
            let size = CGSize(width: width, height: height)
            return size
        }

        func iPadPipSize() -> CGSize {
            guard let parentSize = parentSize else {
                return defaultPipSize()
            }
            let isIpadPortrait = parentSize.width < parentSize.height
            let width = isIpadPortrait ? 80.0 : 152.0
            return CGSize(width: width, height: 115.0)
        }

        return isiPad ? iPadPipSize() : defaultPipSize()
    }

    private func getLimitedValue(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        var limitedValue = value
        if value < min {
            limitedValue = min
        } else if value > max {
            limitedValue = max
        }
        return limitedValue
    }
}


enum ScreenSizeClassType {
    case iphonePortraitScreenSize
    case iphoneLandscapeScreenSize
    case ipadScreenSize
}



public class CallObserver: NSObject, CallDelegate, IncomingCallDelegate {
    private var owner: IncomingCallView
    private var callKitHelper: CallKitHelper?
    
    init(_ view:IncomingCallView) {
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
    private var owner:IncomingCallView
    init(_ view:IncomingCallView) {
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
