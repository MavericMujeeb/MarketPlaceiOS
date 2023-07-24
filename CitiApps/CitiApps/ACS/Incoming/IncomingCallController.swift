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

var incomingCallView: IncomingCallView?

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
    
    var custAcsId:String = "8:acs:ea7ee9db-4146-4c6c-8ffd-8bff35bdd986_00000018-59b7-90bc-6763-563a0d000340"
    var bankerAcsId:String = "8:acs:ea7ee9db-4146-4c6c-8ffd-8bff35bdd986_00000018-59b7-8f91-eaf3-543a0d000ff3"

    var bankerUserName:String! = ACSResources.bankerUserName
    
    func resigterIncomingCallClient (appPubs:AppPubs) {
        self.appPubs = appPubs
        self.pushToken = self.appPubs?.pushToken
        //self.custUserName = UserDefaults.standard.string(forKey: "loginUserName")
        self.isRegisterForIncomingCallNotification = storageUserDefaults.value(forKey: "incomingCallRegistered") as? Bool ?? false

//        if self.isRegisterForIncomingCallNotification == false {
            callParticipantDetailsAPI()
//        }
    }
    
    /*
     * Function to create call agent if incoming call is received when app is closed.
     */
    func registerCallAgent(appPubs:AppPubs, completion: @escaping (Bool) -> Void) {
        self.acsToken =  self.storageUserDefaults.value(forKey: StorageKeys.acsToken) as! String
        
        self.appPubs = appPubs
        self.pushToken = self.appPubs?.pushToken
        
        DispatchQueue.global().async {
            self.callClient.getDeviceManager { (deviceManager, error) in
                if (error == nil) {
                    globalDeviceManager = deviceManager
                    
                    //Communication token credential
                    var userCredential: CommunicationTokenCredential
                    do {
                        userCredential = try CommunicationTokenCredential(token: self.acsToken!)
                    } catch {
                        return
                    }
                    
                    //create call agent
                    self.callClient.createCallAgent(userCredential: userCredential, options: self.createCallAgentOptions()) { (agent, error) in
                        if error == nil {
                            //denit callkit
                            CallKitObjectManager.deInitCallKitInApp()
                            //assign global call agent globally
                            globalCallAgent = agent
                            
                            self.callAgent = agent
                            self.cxProvider = nil
                            self.incomingCallHandler = nil
                            
                            //set incoming call view globally
                            incomingCallView = nil
                            incomingCallView = IncomingCallView(appPubs: self.appPubs!, callAgent: self.callAgent!)
                            self.incomingCallHandler = IncomingCallHandler(contentView: incomingCallView)
                            self.callAgent!.delegate = self.incomingCallHandler
                            //send success message
                            completion(true)
                        }
                        else{
                            //send failure message
                            completion(false)
                        }
                    }
                }
            }
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
                    print("Response Data error -> ")
                    print(error)
                }
                print("Response Data string -> ")
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
                    self.createCallAgent()
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    
    
    func createCallAgent() {
        isCallKitInSDKEnabled = storageUserDefaults.value(forKey: "isCallKitInSDKEnabled") as? Bool ?? false
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
                    if self.deviceManager == nil {
                       self.callClient.getDeviceManager { (deviceManager, error) in
                           if (error == nil) {
                               UIDevice.current.endGeneratingDeviceOrientationNotifications()
                               self.deviceManager = deviceManager
                               incomingCallView?.deviceManager = self.deviceManager
                               globalDeviceManager = deviceManager
                               
                               
                               if self.callAgent != nil {
                                   // Have to dispose existing CallAgent if present
                                   // Because we cannot create two CallAgent's
                                   self.callAgent!.dispose()
                                   self.callAgent = nil
                               }
                               
                               var userCredential: CommunicationTokenCredential
                               do {
                                   userCredential = try CommunicationTokenCredential(token: self.acsToken!)
                               } catch {
                                   return
                               }
                               
                               if (self.isCallKitInSDKEnabled!) {
                                   self.callClient.createCallAgent(userCredential: userCredential, options: self.createCallAgentOptions()) { (agent, error) in
                                       if error == nil {
                                           CallKitObjectManager.deInitCallKitInApp()
                                           self.callAgent = agent
                                           globalCallAgent = agent
                                           self.cxProvider = nil
                                           incomingCallView = nil
                                           self.incomingCallHandler = nil
                                           incomingCallView = IncomingCallView(appPubs: self.appPubs!, callAgent: self.callAgent!)
                                           self.incomingCallHandler = IncomingCallHandler(contentView: incomingCallView)
                                           self.callAgent!.delegate = self.incomingCallHandler
                                           self.registerForPushNotification()
                                       }
                                   }
                               } else {
//                                   self.callClient.createCallAgent(userCredential: userCredential) { (agent, error) in
//                                       if error == nil {
//                                           print("Call agent successfully created (without CallKit)")
//                                           self.callAgent = agent
//                                           incomingCallView = incomingCallView(appPubs: self.appPubs!, callAgent: self.callAgent!)
//                                           self.incomingCallHandler = IncomingCallHandler(contentView: incomingCallView)
//                                           self.callAgent!.delegate = self.incomingCallHandler
//                                           let _ = CallKitObjectManager.getOrCreateCXProvider()
//                                           CallKitObjectManager.getCXProviderImpl().setCallAgent(callAgent: self.callAgent!)
//                                           self.registerForPushNotification()
//                                       }
//                                   }
                               }
                           }
                       }
                    }
                }
            }
        }
    }
    
    func registerForPushNotification() {
        if let callAgent = self.callAgent,
           let pushToken = self.pushToken {
            callAgent.registerPushNotifications(deviceToken: pushToken) { error in
                if error == nil {
                    print("registered for push notifications - call agent & call kit")
                    CircleLoader.sharedInstance.hide()
                    self.storageUserDefaults.setValue(true, forKey: "incomingCallRegistered")
                    //if call is in progress push the incoming call view
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



final class IncomingCallBackgroundHandler: NSObject, CallAgentDelegate, IncomingCallDelegate {
    private var incomingCall: IncomingCall?
    
    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        self.incomingCall = incomingCall
        self.incomingCall!.delegate = self
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

        globalCallAgent = callAgent
        globalIncomingCall = incomingCall

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
        contentView?.incomingCallViewModel.isIncomingCall = false
        self.incomingCall = nil
        Task {
            await CallKitObjectManager.getCallKitHelper()?.removeIncomingCall(callId: incomingCall.id)
        }
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        rootVC?.dismiss(animated: true)
    }
    
    func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        if let removedCall = args.removedCalls.first {
            contentView?.callRemoved(removedCall)
            self.incomingCall = nil
        }

        if let addedCall = args.addedCalls.first {
            // This happens when call was accepted via CallKit and not from the app
            // We need to set the call instances and auto-navigate to call in progress screen.
            
            //ADDED FOR TESTING --
            
            if addedCall.direction == .incoming {
                print("didUpdateCalls")
                print(contentView)
                
                acceptedCall = addedCall as! Call
                let incomingHostingController = ContainerUIHostingController(rootView: contentView!)
                incomingHostingController.modalPresentationStyle = .fullScreen
                PIPKit.show(with: incomingHostingController)
            }
        }
    }
}

class IncomingCallViewController : UIViewController, PIPUsable{}
