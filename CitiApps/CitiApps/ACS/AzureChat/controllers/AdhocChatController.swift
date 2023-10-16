//
//  AdhocChatController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 12/10/23.
//

import Foundation
import AzureCommunicationCalling
import AVFoundation
import AzureCore
import AzureCommunicationUIChat

private struct TokenResponse: Decodable {
    var token: String

    private enum CodingKeys: String, CodingKey {
        case token
    }
}

class AdhocChatController {
    var teamsMeetingUrl: String = ACSResources.teams_scheduled_meeting_url
    var callClient: CallClient = CallClient()
    var callAgent: CallAgent?
    var tokenService: TokenService!
    var chatAdapter: ChatAdapter?
    var commServEndPointURL:String! = "https://acscomunicationservice.communication.azure.com/"
    var token:String?
    
    func getCommunicationToken(completionHandler: @escaping (String?, Error?) -> Void) {
        let communicationTokenUrl = ACSResources.acs_token_fetch_api
        var urlRequest = URLRequest(url: URL(string: communicationTokenUrl)!)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self.token = res.token
                    completionHandler(res.token, nil)
                } catch let error {
                    assertionFailure("Adhoc chat communication token , JSON Parsing of the token response failed.")
                    completionHandler(nil, error)
                }
            }
        }.resume()
    }

    private func createCallKitOptions() -> CallKitOptions {
        let callKitOptions = CallKitOptions(with: CallKitObjectManager.createCXProvideConfiguration())
        callKitOptions.provideRemoteInfo = self.provideCallKitRemoteInfo
        return callKitOptions
    }
    
    func provideCallKitRemoteInfo(callerInfo: CallerInfo) -> CallKitRemoteInfo
    {
        let callKitRemoteInfo = CallKitRemoteInfo()
        let displayName =  users[loggedInUser]?["name"]  ?? ""
        callKitRemoteInfo.displayName =  displayName
        callKitRemoteInfo.handle = CXHandle(type: .generic, value: "VALUE_TO_CXHANDLE")
        return callKitRemoteInfo
    }
    
    private func createCallAgentOptions() -> CallAgentOptions {
        let options = CallAgentOptions()
//        options.callKitOptions = createCallKitOptions()
        return options
    }
    
    func initAdhocChat (){
        CircleLoader.sharedInstance.show()
        getCommunicationToken { token, error in
            if(token != nil){
                AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                    if granted {
                        AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
                            var userCredential: CommunicationTokenCredential
                            do {
                                userCredential = try CommunicationTokenCredential(token: token!)
                            } catch {
                                return
                            }
                            self.callClient.createCallAgent(userCredential: userCredential, options: self.createCallAgentOptions()) { (agent, error) in
                                self.callAgent = agent!
                                let joinLocator = TeamsMeetingLinkLocator(meetingLink: self.teamsMeetingUrl)
                                var joinedCall:Call?
                                let joinCallOptions = JoinCallOptions()
            
                                Task{
                                    do{
                                        try await self.callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions)
                                        self.createChatAdapter()
                                    }
                                    catch{
                                        print("Join call failed.")
                                    }
                                }

                            }
                        }
                    }
                }
            }
                
        }
    }

    func getThreadId(from meetingLink: String) -> String? {
        if let range = meetingLink.range(of: "meetup-join/") {
            let thread = meetingLink[range.upperBound...]
            if let endRange = thread.range(of: "/")?.lowerBound {
                var threadId = String(thread.prefix(upTo: endRange))
                threadId = threadId.replacingOccurrences(of: "%3a", with: ":").replacingOccurrences(of: "%3A", with: ":").replacingOccurrences(of: "%40", with: "@")
                return threadId
            }
        }
        return "nil"
    }

    func createChatAdapter (){
        let loggedInUserId = userid
        let threadId = getThreadId(from: teamsMeetingUrl)!
        let loggedInUserName = loggedInUser
        let displayName = users[loggedInUser]?["name"]  ?? ""
        let communicationIdentifier = CommunicationUserIdentifier(loggedInUserId!)
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token:self.token!) else {
            return
        }
        
        self.chatAdapter = ChatAdapter(
            endpoint: self.commServEndPointURL,
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: threadId,
            displayName: displayName
        )
        
        
        Task { @MainActor in
            
            guard let chatAdapter = self.chatAdapter else {
                return
            }
            chatAdapter.connect(completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.chatAdapter = nil
                case .failure(let error):
                    print("disconnect error \(error)")
                }
            })
            
            let chatCompositeViewController = ChatCompositeViewController(with: chatAdapter, showCallButtons: false)
            let nv = UINavigationController(rootViewController: chatCompositeViewController)
            nv.modalPresentationStyle = .fullScreen
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(nv, animated: false, completion: nil)
        }
    }
}
