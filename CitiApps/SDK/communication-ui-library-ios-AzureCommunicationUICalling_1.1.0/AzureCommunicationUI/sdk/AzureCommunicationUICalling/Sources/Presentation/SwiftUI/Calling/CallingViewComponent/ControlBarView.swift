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
    var teamsMeetingLink : String = ""
    
    init(teamsMeetingLink: String){
        self.teamsMeetingLink = teamsMeetingLink
    }
    
    func sendMessage() {
        print("sendMessage -- trigger")
        print(self.chatMessage)
        print(self.displayName)
        
        let message = SendChatMessageRequest(
            content: self.chatMessage,
            senderDisplayName: self.displayName,
            type: .text
        )
        
        self.chatThreadClient?.send(message: message) { result, _ in
            print(result)
            print("result----------------")
            switch result {
            case .success:
                print("Chat message sent- ")
            case .failure:
                print("Failed to send chat message")
            }

            self.chatMessage = ""
        }
    }
    
    func receiveMessage(eventId: TrouterEvent) {
        print("Message Communication Starts")
//        let chatEvent: ChatMessageReceivedEvent = eventId as! ChatMessageReceivedEvent
//
//        let displayName: String = chatEvent.senderDisplayName ?? "Unknown User"
//        let content: String = chatEvent.message.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression)
//
//        self.meetingMessages.append(
//            MeetingMessage(
//                id: chatEvent.id,
//                content: content,
//                displayName: displayName
//            )
//        )
        print("Message Communication End")
    }
    
    func getThreadId(from meetingLink: String) -> String? {
        if let range = meetingLink.range(of: "meetup-join/") {
            let thread = meetingLink[range.upperBound...]
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
            print("teamsMeetingLink->"+self.teamsMeetingLink)
            // Initialize the ChatClient
            do {
                var sdkVersion = "1.0.0"
                    var applicationId = "Azure_Chat_POC"
                    var sdkName = "azure-communication-com.azure.android.communication.chat"
            
//                var userPolicy = UserAgentPolicy(sdkName: sdkName, sdkVersion: sdkVersion, telemetryOptions: TelemetryOptions(applicationId: applicationId))
                let endpoint = "https://acschatcallingdemo.communication.azure.com/"
                let credential = try CommunicationTokenCredential(token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjYxZmY4Yjg5LTY2ZjktNGMxYS04N2FkLTJlODI2MDc1MzdkNF8wMDAwMDAxNi1hOTI0LTU0NmMtZjBhNy05MjNhMGQwMGUyNjgiLCJzY3AiOjE3OTIsImNzaSI6IjE2NzUxOTI2MTAiLCJleHAiOjE2NzUyNzkwMTAsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQsdm9pcCIsInJlc291cmNlSWQiOiI2MWZmOGI4OS02NmY5LTRjMWEtODdhZC0yZTgyNjA3NTM3ZDQiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjc1MTkyNjEwfQ.aOMHf6QjvmVc5kyM4xOTNbF4QPc4eKQreRNer5n1x76bFvraKd6W1K6RDzWFumsQ-Ma2bmk8A4C0tbICXbjvwbTp69I4VEKZFGtpSBMAxFOn41l6E5KC2VKYtJ06qEFiK6ugzOE__sHYTaNseXyXQejqnv3BHM-eSFeBDQtbAfGkp-ltdxmICoeeloaAa-aYY4VZqCc0qoC2wXGDjLPRH8AMB0xK1qtJUEVvPGI2_9bEY8ZJAOOJZglnlNMmyOwTX6DGW-JzEUocUBuZEN6submY4r77Id7oKeB9z-vr4M_Am8NY9c-m_gitXXeUi1pf_jmP_4qm1kdj7VY8gDRN2g")

                self.chatClient = try ChatClient(
                    endpoint: endpoint,
                    credential: credential,
                    withOptions: AzureCommunicationChatClientOptions()
                )
                print("ChatClient successfully created")

                // Initialize the ChatThreadClient
                       do {
                           guard let threadId = getThreadId(from: self.teamsMeetingLink) else {
                               print("Failed to join meeting chat 3")
                               return
                           }
                           print("threadId --> "+threadId)
                           self.chatThreadClient = try self.chatClient?.createClient(forThread: threadId)
                           print("Joined meeting chat successfully")
                       } catch {
                           print("Failed to create ChatThreadClient")
                           print("Failed to join meeting chat 33")
                           return
                       }
                
//                self.message = "ChatClient successfully created"

                // Start real-time notifications
                self.chatClient?.startRealTimeNotifications() { result in
                    switch result {
                    case .success:
                        print("Real-time notifications started")
                        // Receive chat messages
//                        self.chatClient?.register(event: ChatEventId.chatMessageReceived, handler: receiveMessage)
//                        self.chatClient?.register(event: ChatEventId.chatMessageReceived, handler: receiveMessage)
                        
                        self.chatClient?.register(event: .chatMessageReceived, handler: { response in
                            switch response {
                            case let .chatMessageReceivedEvent(event):
                               
                                let senderDisplayName: String = event.senderDisplayName ?? "Unknown User"
                                let message: String = event.message.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression)
                                
                                print("Received a message: \(event.id) \(senderDisplayName) \(message)")
                                
                                self.meetingMessages.append(
                                            MeetingMessage(
                                                id: event.id,
                                                content: message,
                                                displayName: senderDisplayName
                                            )
                                        )
                            default:
                                return
                            }
                        })

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
            ChatView(teamsMeetingLink: self.viewModel.teamsMeetingLink)
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
