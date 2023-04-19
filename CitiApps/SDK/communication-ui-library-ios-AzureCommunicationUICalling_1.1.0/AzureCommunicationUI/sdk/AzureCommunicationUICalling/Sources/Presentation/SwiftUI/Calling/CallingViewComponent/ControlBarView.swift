//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationChat
import AzureCommunicationCommon
import Trouter
import UIKit
import AzureCommunicationUIChat
import ReplayKit
import PIPKit


struct AcsUserIdToken: Codable {
    
    var acsEndpoint: String? = ""
    var bankerUserId: String? = ""
    var bankerUserToken: String? = ""
    var customerUserId: String? = ""
    var customerUserToken: String? = ""
}

struct ParticipantDetails: Codable {
    let originator: Participant?
    let participantList: [Participant]?
}

struct Participant: Codable {
    let participantName, participantId, acsId, participantType: String?
    let threadId: String?
}

class ChatViewController : UIViewController{
    
    var chatAdapter: ChatAdapter?
    //    var threadId:String!
    
    var commServEndPointURL:String! = "https://acscallchatcomserv.communication.azure.com/"
    var threadId:String! = ""
    var bankerAcsId:String! = ""
    var bankerUserToken:String! = ""
    var bankerEmailId:String! = ""
    var bankerUserName:String! = ""
    var custAcsId:String! = ""
    var custUserToken:String! = ""
    var custUserName:String! = "Janet Johnson"
    var isTeamsChat : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isTeamsChat {
            startTeamsChatComposite()
        }else{
            prepareChatComposite()
        }
    }
    
    func prepareChatComposite() {
        self.callParticipantDetailsAPI()
    }
    
    func initializeChatComposite() {
        
        do{
            let credential = try CommunicationTokenCredential(
                token: self.bankerUserToken
            )
            let options = AzureCommunicationChatClientOptions()
            
            let chatClient = try ChatClient(
                endpoint: self.commServEndPointURL,
                credential: credential,
                withOptions: options
            )
            let request = CreateChatThreadRequest(
                topic: "30-min meeting",
                participants: [
                    ChatParticipant(
                        id: CommunicationUserIdentifier(self.bankerAcsId),
                        displayName: self.bankerUserName
                    ),
                ]
            )
            
            chatClient.create(thread: request) { result, _ in
                switch result {
                case let .success(result):
                    self.startChatComposite()
                case .failure:
                    print(result)
                }
            }
        }
        catch {
            //hanle the error
        }
    }
    
    @objc private func startChatComposite() {
        let communicationIdentifier = CommunicationUserIdentifier(self.custAcsId)
        
        
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:self.custUserToken) else {
            return
        }
        
        self.chatAdapter = ChatAdapter(
            endpoint: self.commServEndPointURL,
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: self.threadId,
            displayName: self.custUserName)
        
        Task { @MainActor in
            guard let chatAdapter = self.chatAdapter else {
                return
            }
            chatAdapter.connect(completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.chatAdapter = nil
                    print("success -- chatadapter")
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
            
            let chatCompositeViewController = ChatCompositeViewController(
                with: chatAdapter,showCallButtons: false)
            chatCompositeViewController.onCloseChatCompositeViewcompletion = {
                self.dismiss(animated: false)
            }
            let nv = UINavigationController(rootViewController: chatCompositeViewController)
            nv.modalPresentationStyle = .fullScreen
            self.present(nv, animated: false, completion: nil)
        }
    }
    
    func callUserTokenAPI() {
        let progressIndiactor = self.showProgressIndicator
        let fullUrl: String = "https://acscallchattokenfunc.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
        
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            self.hideProgressIndicator(indicator: progressIndiactor)
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(AcsUserIdToken.self, from: data)
                    self.custUserToken = responseModel.customerUserToken
                    self.bankerUserToken = responseModel.bankerUserToken
                    self.initializeChatComposite()
                } catch {
                    print("Response Data error -> ")
                    print(error)
                }
                print("Response Data string -> ")
                print(string)
            }
        }
        task.resume()
    }
    
    func callParticipantDetailsAPI() {
        let progressIndiactor = self.showProgressIndicator
        self.bankerEmailId = UserDefaults.standard.string(forKey: "bankerEmailId")
        let reqBody = "{" +
        "\"originatorId\":\"\(self.bankerEmailId!)\"," +
        "\"participantName\":\"\(self.custUserName!)\"" +
        "}"
        
        let fullUrl: String = "https://service-20230322105302607.azurewebsites.net/api/participantDetails"
        
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = reqBody.data(using: .utf8)!
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            self.hideProgressIndicator(indicator: progressIndiactor)
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ParticipantDetails.self, from: data)
                    self.bankerUserName = responseModel.originator?.participantName
                    self.bankerAcsId = responseModel.originator?.acsId
                    self.custUserName = responseModel.participantList?[0].participantName
                    self.custAcsId = responseModel.participantList?[0].acsId
                    self.threadId = responseModel.participantList?[0].threadId
                    self.callUserTokenAPI()
                } catch {
                    print("Response Data error -> ")
                    print(error)
                }
                print("Response Data string -> ")
                print(string)
            }
        }
        task.resume()
    }
    //    override func viewWillLayoutSubviews() {
    //      let width = self.view.frame.width
    //      let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
    //      self.view.addSubview(navigationBar);
    //      let navigationItem = UINavigationItem(title: "Chat")
    //        let closeItem = UIBarButtonItem(
    //            barButtonSystemItem: .close,
    //            target: self,
    //            action: #selector(self.onBackBtnPressed(_ :))
    //        )
    //      navigationItem.leftBarButtonItem = closeItem
    //      navigationBar.setItems([navigationItem], animated: false)
    //    }
    
    @objc func onBackBtnPressed (){
        print("onBackBtnPressed")
        self.dismiss(animated: true, completion: nil)
        Task { @MainActor in
            self.chatAdapter?.disconnect(completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.chatAdapter = nil
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
        }
    }
    
    @objc private func startTeamsChatComposite() {
        
        
        let communicationIdentifier = CommunicationUserIdentifier(loggedInUserId)
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:communincationTokenString) else {
            return
        }
        
        self.chatAdapter = ChatAdapter(
            endpoint: "https://acscallchatcomserv.communication.azure.com/",
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: threadId,
            displayName: loggedInUserName)
        
        
        Task { @MainActor in
            
            guard let chatAdapter = self.chatAdapter else {
                print("returning chat adapter")
                return
            }
            chatAdapter.connect(completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.chatAdapter = nil
                    print("success -- chatadapter")
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
            
            let chatCompositeViewController = ChatCompositeViewController(
                with: chatAdapter,showCallButtons: false)
            let nv = UINavigationController(rootViewController: chatCompositeViewController)
            nv.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true, completion: nil)
            self.present(nv, animated: false, completion: nil)
        }
    }
}

struct ChatScreen: UIViewControllerRepresentable{
    
    var threadId : String!
    var isTeamsChat : Bool!
    
    init(threadId: String!,isTeamsChat : Bool = true) {
        self.isTeamsChat = isTeamsChat
        if isTeamsChat {
            self.threadId = threadId
        }
    }
    typealias UIViewControllerType = ChatViewController
    
    func makeUIViewController(context: Context) -> ChatViewController {
        let vc = ChatViewController()
        if isTeamsChat {
            vc.threadId = threadId;
        }
        vc.isTeamsChat = isTeamsChat
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ChatViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
        print("updateUIViewController")
    }
}

struct ControlBarView: View {
    @ObservedObject var viewModel: ControlBarViewModel
    
    // anchor views for drawer views on (iPad)
    @State var audioDeviceButtonSourceView = UIView()
    @State var leaveCallConfirmationListSourceView = UIView()
    
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType
    
    func getThreadId(from meetingLink: String) -> String? {
        if let range = meetingLink.range(of: "meetup-join/") {
            let thread = meetingLink[range.upperBound...]
            if let endRange = thread.range(of: "/")?.lowerBound {
                var threadId = String(thread.prefix(upTo: endRange))
                threadId = threadId.replacingOccurrences(of: "%3a", with: ":").replacingOccurrences(of: "%3A", with: ":").replacingOccurrences(of: "%40", with: "@")
                print("threadId is :\(threadId)")
                return threadId
            }
        }
        return nil
    }
    
    var body: some View {
        Group {
            if screenSizeClass == .ipadScreenSize {
                centeredStack
            } else {
                nonCenteredStack
            }
        }
        .padding()
        .background(Color(StyleProvider.color.backgroundColor))
        .modifier(PopupModalView(isPresented: viewModel.isAudioDeviceSelectionDisplayed) {
            audioDeviceSelectionListView
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        })
        .modifier(PopupModalView(isPresented: viewModel.isConfirmLeaveListDisplayed) {
            exitConfirmationDrawer
                .accessibility(hidden: !viewModel.isConfirmLeaveListDisplayed)
                .accessibilityElement(children: .contain)
                .accessibility(addTraits: .isModal)
        })
    }
    
    /// A stack view that has items centered aligned horizontally in its stack view
    var centeredStack: some View {
        Group {
            if screenSizeClass != .iphoneLandscapeScreenSize {
                HStack {
                    Spacer()
                    videoButton
                    micButton
                    audioDeviceButton
                    chatButton
                    hangUpButton
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    hangUpButton
                    chatButton
                    audioDeviceButton
                    micButton
                    videoButton
                    Spacer()
                }
            }
        }
    }
    
    /// A stack view that has items that take the stakview space evenly
    var nonCenteredStack: some View {
        Group {
            if screenSizeClass != .iphoneLandscapeScreenSize {
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
                }
            } else {
                VStack {
                    hangUpButton
                    Spacer()
                    chatButton
                    Spacer()
                    micButton
                    Spacer()
                    videoButton
                    Spacer()
                    screenShareButton
                    
                }
            }
        }
    }
    
    var videoButton: some View {
        IconButton(viewModel: viewModel.cameraButtonViewModel)
            .disabled(viewModel.isCameraDisabled())
            .accessibility(identifier: AccessibilityIdentifier.videoAccessibilityID.rawValue)
    }
    
    var micButton: some View {
        IconButton(viewModel: viewModel.micButtonViewModel)
            .disabled(viewModel.isMicDisabled())
            .accessibility(identifier: AccessibilityIdentifier.micAccessibilityID.rawValue)
    }
    
    @State var shouldPresentChat = false
    var chatButton: some View {
        Group{
            Button(
                action: {
                    PIPKit.visibleViewController?.stopPIPMode()
                    shouldPresentChat.toggle()
                }) {
                    Image(uiImage: UIImage(named: "teamchat")!)
                        .renderingMode(.original)
                        .font(.title)
                        .foregroundColor(.black)
                }
        }.fullScreenCover(isPresented: $shouldPresentChat, content: {
            if self.viewModel.teamsMeetingLink.isEmpty {
                ChatScreen(threadId: "",isTeamsChat: false)
            }else{
                ChatScreen(threadId: getThreadId(from: self.viewModel.teamsMeetingLink))
            }
        })
        
    }
    
    var screenShareButton: some View {
        IconButton(viewModel: viewModel.screenShareButtonViewModel)
            .disabled(viewModel.isScreenShareDisabled())
            .accessibility(identifier: "Screen_Share")
    }
    
    var audioDeviceButton: some View {
        IconButton(viewModel: viewModel.audioDeviceButtonViewModel)
            .background(SourceViewSpace(sourceView: audioDeviceButtonSourceView))
            .accessibility(identifier: AccessibilityIdentifier.audioDeviceAccessibilityID.rawValue)
        
    }
    
    var hangUpButton: some View {
        IconButton(viewModel: viewModel.hangUpButtonViewModel)
            .background(SourceViewSpace(sourceView: leaveCallConfirmationListSourceView))
            .accessibilityIdentifier(AccessibilityIdentifier.hangupAccessibilityID.rawValue)
    }
    
    var audioDeviceSelectionListView: some View {
        CompositeAudioDevicesList(isPresented: $viewModel.isAudioDeviceSelectionDisplayed,
                                  viewModel: viewModel.audioDevicesListViewModel,
                                  sourceView: audioDeviceButtonSourceView)
        .modifier(LockPhoneOrientation())
    }
    
    func leaveCall(){
        print("leaveCall ----- ")
    }
    
    var exitConfirmationDrawer: some View {
        CompositeLeaveCallConfirmationList(isPresented: $viewModel.isConfirmLeaveListDisplayed,
                                           viewModel: viewModel.getLeaveCallConfirmationListViewModel(),
                                           sourceView: leaveCallConfirmationListSourceView, callBack: leaveCall)
        .modifier(LockPhoneOrientation())
    }
}

struct LeaveCallConfirmationListViewModel {
    let headerName: String?
    let listItemViewModel: [LeaveCallConfirmationViewModel]
}

extension UIViewController {
    
    var showProgressIndicator:UIActivityIndicatorView? {
        let screen = UIScreen.main.bounds
        let indicator: UIActivityIndicatorView? = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        DispatchQueue.main.async {
            indicator?.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0)
            indicator?.frame.origin.x = (screen.width/2 - 20)
            indicator?.frame.origin.y = (screen.height/2 - 20)
            self.view.addSubview(indicator!)
            indicator?.startAnimating()
        }
        return indicator
    }
    
    func hideProgressIndicator(indicator: UIActivityIndicatorView?) {
        DispatchQueue.main.async {
            indicator?.stopAnimating()
            indicator?.removeFromSuperview()
        }
    }
}
