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

class ChatViewController : UIViewController{
    
    var chatAdapter: ChatAdapter?
    var threadId:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        startChatComposite()
    }
    
    override func viewWillLayoutSubviews() {
      let width = self.view.frame.width
      let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
      self.view.addSubview(navigationBar);
      let navigationItem = UINavigationItem(title: "Chat")
        let closeItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(self.onBackBtnPressed(_ :))
        )
      navigationItem.leftBarButtonItem = closeItem
      navigationBar.setItems([navigationItem], animated: false)
    }
    
    @objc func onBackBtnPressed (_ sender: UIBarButtonItem){
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

    @objc private func startChatComposite() {
        
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
            with: chatAdapter)
        self.view.addSubview(chatCompositeViewController.view)
    }
}

struct ChatScreen: UIViewControllerRepresentable{
    
    var threadId : String!
    
    init(threadId: String!) {
        self.threadId = threadId
    }
    typealias UIViewControllerType = ChatViewController
    
    func makeUIViewController(context: Context) -> ChatViewController {
        let vc = ChatViewController()
        vc.threadId = threadId;
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
        }.sheet(isPresented: $shouldPresentChat, content: {
            ChatScreen(threadId: getThreadId(from: self.viewModel.teamsMeetingLink))
        })
        
    }
    
    var screenShareButton: some View {
        IconButton(viewModel: viewModel.screenShareButtonViewModel)
            .disabled(false)
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
