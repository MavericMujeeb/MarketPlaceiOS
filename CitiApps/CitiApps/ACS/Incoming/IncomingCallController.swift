//
//  IncomingCallController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 20/04/23.
//

import Foundation
import AzureCommunicationCalling
import AVFoundation
import SwiftUI
import PIPKit

struct IncomingCallScreen: View{

    var body: some View {
        EmptyView()
    }
}

class ACSIncomingCallConntroller{
    
    var callClient = CallClient()
    var callAgent: CallAgent?
    var call: Call?
    var deviceManager: DeviceManager?
    var acsToken:String?
    var isCallKitInSDKEnabled:Bool?
    var isRegisterForIncomingCallNotification:Bool = false
    var incomingCallHandler:IncomingCallHandler?
    var cxProvider: CXProvider?
    var pushToken: Data?
    
    var appPubs:AppPubs?
    let storageUserDefaults = UserDefaults.standard
    
    var custUserName:String! = UserDefaults.standard.string(forKey: "loginUserName")
    var bankerEmailId:String! = UserDefaults.standard.string(forKey: "bankerEmailId")
    
    var custAcsId:String = ""
    var bankerAcsId:String = ""
    var bankerUserName:String! = ACSResources.bankerUserName
    
    func resigterIncomingCallClient (appPubs:AppPubs) {
        self.appPubs = appPubs
        self.pushToken = self.appPubs?.pushToken
        self.isRegisterForIncomingCallNotification = storageUserDefaults.value(forKey: "incomingCallRegistered") as? Bool ?? false
        if self.isRegisterForIncomingCallNotification == false {
            callParticipantDetailsAPI()
        }
    }
    
    func callParticipantDetailsAPI() {
        self.bankerEmailId = self.bankerEmailId ?? ACSResources.bankerUserEmail
        let reqBody = "{" +
        "\"originatorId\":\"\(self.bankerEmailId!)\"," +
        "\"participantName\":\"\(self.custUserName!)\"" +
        "}"

        let fullUrl: String = ACSResources.acs_chat_participantdetails_api
        
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = reqBody.data(using: .utf8)!
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            

            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ParticipantDetails.self, from: data)
                    self.bankerAcsId = (responseModel.originator?.acsId)!
                    self.custAcsId = (responseModel.participantList?[0].acsId)!
                    
                    self.bankerUserName = responseModel.originator?.participantName
                    
                    self.getCustomerCommunicationToken()
                    
                } catch {
                    print(error)
                }
                print(string)
            }
        }
        task.resume()
    }
    
    func getCustomerCommunicationToken () {
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
        let task = URLSession.shared.dataTask(with: URL(string: fullUrl)!){
            data, response, error in
            if let data = data{
                do {
                    let jsonDecoder = JSONDecoder()
                    let res = try JSONDecoder().decode(AcsUserIdToken.self, from: data)
                    self.acsToken = res.customerUserToken
                    //cache the token
                    self.storageUserDefaults.set(self.acsToken, forKey: StorageKeys.acsToken)
                    self.registerIncomingCallPushNotifications()
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func registerIncomingCallPushNotifications() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
                    
                    var userCredential: CommunicationTokenCredential
                    do {
                        userCredential = try CommunicationTokenCredential(token: self.acsToken!)
                    } catch {
                        return
                    }
                    self.callClient.createCallAgent(userCredential: userCredential, options: self.createCallAgentOptions()) { (agent, error) in
                        if let callAgent = agent, let pushToken = self.pushToken {
                            callAgent.registerPushNotifications(deviceToken: pushToken) { error in
                                if error == nil {
                                    print("registered for push notifications - call agent & call kit")
                                    self.storageUserDefaults.setValue(true, forKey: "incomingCallRegistered")
                                    //dispose call agent once successfully registerd for push notifications.
                                    callAgent.dispose()
                                    CircleLoader.sharedInstance.hide()
                                }
                            }
                        }
                    }

                }
            }
        }
    }

    func provideCallKitRemoteInfo(callerInfo: CallerInfo) -> CallKitRemoteInfo
    {
        let callKitRemoteInfo = CallKitRemoteInfo()
        callKitRemoteInfo.displayName = self.bankerUserName
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
}

final class IncomingCallHandler: NSObject, CallAgentDelegate, IncomingCallDelegate {
    public var contentView: IncomingCallView?
    private var incomingCall: IncomingCall?

    init(contentView: IncomingCallView?) {
        self.contentView = contentView
    }

    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        
        self.incomingCall = incomingCall
        self.incomingCall!.delegate = self
        
        contentView?.showIncomingCallBanner(self.incomingCall!)
        // If there is no CallKitHelper exit
        guard let callKitHelper =  CallKitObjectManager.getCallKitHelper() else {
            return
        }
        Task {
            await CallKitObjectManager.getCallKitHelper()?.addIncomingCall(incomingCall: self.incomingCall!)
        }
        let incomingCallReporter = CallKitIncomingCallReporter()
        incomingCallReporter.reportIncomingCall(callId: self.incomingCall!.id,
                                               callerInfo: self.incomingCall!.callerInfo,
                                               videoEnabled: self.incomingCall!.isVideoEnabled,
                                               completionHandler: { error in
            if error == nil {
                print("Incoming call was reportd successfully")
            } else {
                print("Incoming call was not reported successfully")
            }
        })
    }

    func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
        self.incomingCall = nil
        Task {
            await CallKitObjectManager.getCallKitHelper()?.removeIncomingCall(callId: incomingCall.id)
        }
        PIPKit.dismiss(animated: true)
        self.contentView = nil
    }
    
    
    func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        if let removedCall = args.removedCalls.first {
            print("didUpdateCalls")
            contentView?.callRemoved(removedCall)
            self.incomingCall = nil
            PIPKit.dismiss(animated: true)
            self.contentView = nil
        }

        if let addedCall = args.addedCalls.first {
            // This happens when call was accepted via CallKit and not from the app
            // We need to set the call instances and auto-navigate to call in progress screen.
            if addedCall.direction == .incoming {
                contentView?.setCallAndObersever(call: addedCall, error: nil)
            }
        }
    }
}

class IncomingCallViewController : UIViewController, PIPUsable{}
