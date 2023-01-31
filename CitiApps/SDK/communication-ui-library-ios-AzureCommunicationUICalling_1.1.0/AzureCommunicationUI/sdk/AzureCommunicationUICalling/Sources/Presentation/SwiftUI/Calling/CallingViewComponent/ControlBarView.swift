//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationChat
import AzureCommunicationCommon
import Trouter

struct MeetingMessage {
    let id: String
    let content: String
    let displayName: String
}

struct ChatView: View{
    // Chat
    @State var chatClient: ChatClient?
    @State var chatThreadClient: ChatThreadClient?
    @State var chatMessage: String = ""
    @State var meetingMessages: [MeetingMessage] = []

    let displayName: String = "Janet Johnson"
    
    var message : String = ""
    var meetingLink: String!
    
    func sendMessage() {
        print("sendMessage -- trigger")
        print(self.chatMessage)
        print(self.displayName)
        
        let message = SendChatMessageRequest(
            content: self.chatMessage,
            senderDisplayName: self.displayName
        )
        
        self.chatThreadClient?.send(message: message) { result, _ in
            print(result)
            print("result----------------")
            switch result {
            case .success:
                print("Chat message sent")
            case .failure:
                print("Failed to send chat message")
            }

            self.chatMessage = ""
        }
    }
    func receiveMessage(response: Any, eventId: ChatEventId) {
        let chatEvent: ChatMessageReceivedEvent = response as! ChatMessageReceivedEvent

        let displayName: String = chatEvent.senderDisplayName ?? "Unknown User"
        let content: String = chatEvent.message.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression)

        self.meetingMessages.append(
            MeetingMessage(
                id: chatEvent.id,
                content: content,
                displayName: displayName
            )
        )
    }
    
    func getThreadId(from meetingLink: String) -> String? {
        if let range = self.meetingLink.range(of: "meetup-join/") {
            let thread = self.meetingLink[range.upperBound...]
            if let endRange = thread.range(of: "/")?.lowerBound {
                return String(thread.prefix(upTo: endRange))
            }
        }
        return nil
    }
    
    func leaveMeeting() {
//        if let call = call {
//            call.hangUp(options: nil, completionHandler: { (error) in
//                if error == nil {
//                    self.message = "Leaving Teams meeting was successful"
//                    // Clear the chat
//                    self.meetingMessages.removeAll()
//                } else {
//                    self.message = "Leaving Teams meeting failed"
//                }
//            })
//        } else {
//            self.message = "No active call to hanup"
//        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(meetingMessages, id: \.id) { message in
                let currentUser: Bool = (message.displayName == self.displayName)
                let foregroundColor = currentUser ? Color.white : Color.black
                let background = currentUser ? Color.blue : Color(.systemGray6)
                let alignment = currentUser ? HorizontalAlignment.trailing : HorizontalAlignment.leading
                VStack {
                    Text(message.displayName).font(Font.system(size: 10))
                    Text(message.content)
                }
                .alignmentGuide(.leading) { d in d[alignment] }
                .padding(10)
                .foregroundColor(foregroundColor)
                .background(background)
                .cornerRadius(10)
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
        TextField("Enter your message...", text: $chatMessage)
        Button(action: sendMessage) {
            Text("Send Message")
        }.onAppear{
            print("on appear")
            // Initialize the ChatClient
            do {
                let endpoint = "https://acschatcallingdemo.communication.azure.com"
                let credential = try CommunicationTokenCredential(token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjYxZmY4Yjg5LTY2ZjktNGMxYS04N2FkLTJlODI2MDc1MzdkNF8wMDAwMDAxNi1hNjE1LWNiMDUtMGQ4Yi0wODQ4MjIwMDdiMDgiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzUxNDEzMjYiLCJleHAiOjE2NzUyMjc3MjYsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQsdm9pcCIsInJlc291cmNlSWQiOiI2MWZmOGI4OS02NmY5LTRjMWEtODdhZC0yZTgyNjA3NTM3ZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc1MTQxMzI2fQ.cW0C1-a3LYfpt3eKNp16HXUokR8Qk5XpWAlmUEhzHEJam37E-QDOx3wHnzVRsV1EavYTdjSrPrdJb572qVmWetVb2FtxBDhyOFoI3sHj7Tv9sExrYYw3s9kq2FGf0c2kE4pfDzswxj1vRBgXNm9JQvBT1eUi0kgADaTYXJyMpgyQXe_fc8yMcaM_lQJTQvi6RL_QRfZUNsK67Si8qWtK1md440f4C0MV1E3opL2izyarG2bqpz0AIT4oQlL3kvoKwATTddOQl2nPwJZyi3U1CngwSWF4R7m36x85Xd4_pBkE3Mdvhbt5jgyxSd-JFaPsuAJKGzu9WciWbObQ6e5PBQ")

                self.chatClient = try ChatClient(
                    endpoint: endpoint,
                    credential: credential,
                    withOptions: AzureCommunicationChatClientOptions()
                )
                print("ChatClient successfully created")

//                self.message = "ChatClient successfully created"

                // Start real-time notifications
                self.chatClient?.startRealTimeNotifications() { result in
                    switch result {
                    case .success:
                        print("Real-time notifications started")
                        // Receive chat messages
//                        self.chatClient?.register(event: ChatEventId.chatMessageReceived, handler: receiveMessage)
//                        self.chatClient?.register(event: ChatEventId.chatMessageReceived, handler: receiveMessage)

                    case .failure:
                        print("Failed to start real-time notifications")
//                        self.message = "Failed to enable chat notifications"
                    }
                }
            } catch {
                print("Unable to create ChatClient")
//                self.message = "Please enter a valid endpoint and Chat token in source code"
                return
            }
        }
        
//        NavigationView {
//            VStack(alignment: .leading) {
//                ForEach(meetingMessages, id: \.id) { message in
//                    let currentUser: Bool = (message.displayName == self.displayName)
//                    let foregroundColor = currentUser ? Color.white : Color.black
//                    let background = currentUser ? Color.blue : Color(.systemGray6)
//                    let alignment = currentUser ? HorizontalAlignment.trailing : HorizontalAlignment.leading
//                    VStack {
//                        Text(message.displayName).font(Font.system(size: 10))
//                        Text(message.content)
//                    }
//                    .alignmentGuide(.leading) { d in d[alignment] }
//                    .padding(10)
//                    .foregroundColor(foregroundColor)
//                    .background(background)
//                    .cornerRadius(10)
//                }
//            }.frame(minWidth: 0, maxWidth: .infinity)
//            TextField("Enter your message...", text: $chatMessage)
//            Button(action: sendMessage) {
//                Text("Send Message")
//            }
//        }.onAppear{
//            // Initialize the ChatClient
//            do {
//                let endpoint = "COMMUNICATION_SERVICES_RESOURCE_ENDPOINT_HERE>"
//                let credential = try CommunicationTokenCredential(token: "<USER_ACCESS_TOKEN_HERE>")
//
//                self.chatClient = try ChatClient(
//                    endpoint: endpoint,
//                    credential: credential,
//                    withOptions: AzureCommunicationChatClientOptions()
//                )
//
////                self.message = "ChatClient successfully created"
//
//                // Start real-time notifications
//                self.chatClient?.startRealTimeNotifications() { result in
//                    switch result {
//                    case .success:
//                        print("Real-time notifications started")
//                        // Receive chat messages
////                        self.chatClient?.register(event: ChatEventId.chatMessageReceived, handler: receiveMessage)
//
//                    case .failure:
//                        print("Failed to start real-time notifications")
////                        self.message = "Failed to enable chat notifications"
//                    }
//                }
//            } catch {
//                print("Unable to create ChatClient")
////                self.message = "Please enter a valid endpoint and Chat token in source code"
//                return
//            }
//        }
    }
}

struct ControlBarView: View {
    @ObservedObject var viewModel: ControlBarViewModel

    // anchor views for drawer views on (iPad)
    @State var audioDeviceButtonSourceView = UIView()
    @State var leaveCallConfirmationListSourceView = UIView()

    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

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
            ChatView()
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

    var exitConfirmationDrawer: some View {
        CompositeLeaveCallConfirmationList(isPresented: $viewModel.isConfirmLeaveListDisplayed,
                                           viewModel: viewModel.getLeaveCallConfirmationListViewModel(),
                                           sourceView: leaveCallConfirmationListSourceView)
            .modifier(LockPhoneOrientation())
    }
}

struct LeaveCallConfirmationListViewModel {
    let headerName: String?
    let listItemViewModel: [LeaveCallConfirmationViewModel]
}
