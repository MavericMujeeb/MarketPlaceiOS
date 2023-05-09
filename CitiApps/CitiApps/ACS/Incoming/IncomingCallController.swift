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
    var incomingCallHandler:IncomingCallHandler?
    var cxProvider: CXProvider?
    var pushToken: Data?
    var incomingCallView: ContentView?
    var appPubs:AppPubs?
    let storageUserDefaults = UserDefaults.standard
    
    func resigterIncomingCallClient (appPubs:AppPubs) {
//        getCustomerCommunicationToken()
        self.appPubs = appPubs
        self.pushToken = self.appPubs?.pushToken
    }
    
    func getCustomerCommunicationToken () {
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/"
        let task = URLSession.shared.dataTask(with: URL(string: fullUrl)!){
            data, response, error in
            CircleLoader.sharedInstance.hide()
            if let data = data{
                do {
                    let jsonDecoder = JSONDecoder()
                    let res = try JSONDecoder().decode(AcsUserIdToken.self, from: data)
                    self.acsToken = res.customerUserToken
                    //cache the token
                    self.storageUserDefaults.set(self.acsToken, forKey: StorageKeys.acsToken)
                    self.createCallAgent()
                } catch {
                    print("Response Data error -> ")
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func createCallAgent() {
        self.incomingCallView = ContentView(appPubs: self.appPubs!)
        isCallKitInSDKEnabled = storageUserDefaults.value(forKey: "isCallKitInSDKEnabled") as? Bool ?? false
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
                    if self.deviceManager == nil {
                       self.callClient.getDeviceManager { (deviceManager, error) in
                           if (error == nil) {
                               UIDevice.current.endGeneratingDeviceOrientationNotifications()
                               self.deviceManager = deviceManager
                               
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
                                           print("Call agent successfully created.")
                                           CallKitObjectManager.deInitCallKitInApp()
                                           self.callAgent = agent
                                           self.cxProvider = nil
                                           self.incomingCallHandler = IncomingCallHandler(contentView: self.incomingCallView)
                                           self.callAgent!.delegate = self.incomingCallHandler
                                           self.registerForPushNotification()
                                       }
                                   }
                               } else {
                                   self.callClient.createCallAgent(userCredential: userCredential) { (agent, error) in
                                       if error == nil {
                                           print("Call agent successfully created (without CallKit)")
                                           self.callAgent = agent
                                           self.incomingCallHandler = IncomingCallHandler(contentView: self.incomingCallView)
                                           self.callAgent!.delegate = self.incomingCallHandler
                                           let _ = CallKitObjectManager.getOrCreateCXProvider()
                                           CallKitObjectManager.getCXProviderImpl().setCallAgent(callAgent: self.callAgent!)
                                           self.registerForPushNotification()
                                       }
                                   }
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
                    print("registered for push notifications")
                }
            }
        }
    }
    
    func provideCallKitRemoteInfo(callerInfo: CallerInfo) -> CallKitRemoteInfo
    {
        let callKitRemoteInfo = CallKitRemoteInfo()
        callKitRemoteInfo.displayName = "CALL_TO_PHONENUMBER_BY_APP"
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
    public var contentView: ContentView?
    private var incomingCall: IncomingCall?

    init(contentView: ContentView?) {
        self.contentView = contentView
    }

    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        print("didRecieveIncomingCall -- call agent")
        self.incomingCall = incomingCall
        self.incomingCall!.delegate = self
        contentView?.showIncomingCallBanner(self.incomingCall!)
        Task {
            await CallKitObjectManager.getCallKitHelper()?.addIncomingCall(incomingCall: self.incomingCall!)
        }
        let incomingCallReporter = CallKitIncomingCallReporter()
        incomingCallReporter.reportIncomingCall(callId: self.incomingCall!.id,
                                               callerInfo: self.incomingCall!.callerInfo,
                                               videoEnabled: self.incomingCall!.isVideoEnabled,
                                               completionHandler: { error in
            if error == nil {
                print("Incoming call was reported successfully")
            } else {
                print("Incoming call was not reported successfully")
            }
        })
    }

    func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
        contentView?.isIncomingCall = false
        self.incomingCall = nil
        Task {
            await CallKitObjectManager.getCallKitHelper()?.removeIncomingCall(callId: incomingCall.id)
        }
    }
    
    func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        if let removedCall = args.removedCalls.first {
            contentView?.callRemoved(removedCall)
            self.incomingCall = nil
        }

        if let addedCall = args.addedCalls.first {
            // This happens when call was accepted via CallKit and not from the app
            // We need to set the call instances and auto-navigate to call in progress screen.
            if addedCall.direction == .incoming {
                contentView?.isIncomingCall = false
                contentView?.setCallAndObersever(call: addedCall, error: nil)
            }
        }
    }
}
