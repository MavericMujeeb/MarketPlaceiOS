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

class ChatViewController : UIViewController{
    
    var chatAdapter: ChatAdapter?
    var threadId:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        startChatComposite()
    }

    @objc private func startChatComposite() {
        print("loggedInUserId")
        print(loggedInUserId)
        let communicationIdentifier = CommunicationUserIdentifier(loggedInUserId)
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:"eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjYxZmY4Yjg5LTY2ZjktNGMxYS04N2FkLTJlODI2MDc1MzdkNF8wMDAwMDAxNi1jNWYwLTExYTQtM2RmZS05YzNhMGQwMDE3ZjciLCJzY3AiOjE3OTIsImNzaSI6IjE2NzU2NzU3MjUiLCJleHAiOjE2NzU3NjIxMjUsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAiLCJyZXNvdXJjZUlkIjoiNjFmZjhiODktNjZmOS00YzFhLTg3YWQtMmU4MjYwNzUzN2Q0IiwicmVzb3VyY2VMb2NhdGlvbiI6InVuaXRlZHN0YXRlcyIsImlhdCI6MTY3NTY3NTcyNX0.fNIGK__erJayQ9oks5DjlvItWeGbTYm7IXbWwMJxwumoTn1ypQfpjxbojCAylvnhlbuKdwWnSIUTllBk0hDRp7BRT6dUqkwIrPdy27lH85OWctBNOInjbpqdvLI-YCjKrKgQ9o4qVntIx-Qw_0GoaA5bXKKB7fJujkr4-Eux4QB9WKZMsPc-LJVGqpSr-1F4qt8_kG-1tibnZTDMYntc2FJncM0rIEjgsE2GtAx4d0BaaNAnF7qenOTKlLkLfj0wW9kYRUMF02OBpZ5tv9bFr4mEnq4SRNTkkpPIlsC5sOHmtCtny9WbLaPYcnZaFjTnckQcF8UWR2k3p5QYEDtLsA") else {
            return
        }

        self.chatAdapter = ChatAdapter(
            endpoint: "https://acschatcallingdemo.communication.azure.com/",
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: threadId,
            displayName: loggedInUserName)

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
                with: chatAdapter)
            let navController = UINavigationController(rootViewController: chatCompositeViewController)
            navController.modalPresentationStyle = .pageSheet
            self.dismiss(animated: false, completion: nil)
            self.present(navController, animated: false, completion: nil)

        }
    }

    @objc func onBackBtnPressed() {
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
                    audioDeviceButton
                    Spacer()
                    chatButton
                    Spacer()
                    hangUpButton
                }
            } else {
                VStack {
                    hangUpButton
                    Spacer()
                    audioDeviceButton
                    Spacer()
                    micButton
                    Spacer()
                    videoButton
                    Spacer()
                    chatButton
                    
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
