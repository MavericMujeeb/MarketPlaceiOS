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

class ACSIncomingCallController {
    
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
            self.fetchACSParticipantDetails()
        }
    }
    
    private func fetchACSParticipantDetails() {
        self.bankerEmailId = self.bankerEmailId ?? ACSResources.bankerUserEmail
        storageUserDefaults.set(self.bankerEmailId, forKey: StorageKeys.bankerEmailId)
        
        NetworkManager.shared.getAcsParticipantDetails { response, error in
            if(error == nil){
                self.bankerAcsId = (response.originator?.acsId)!
                self.custAcsId = (response.participantList?[0].acsId)!
                self.bankerUserName = response.originator?.participantName
                self.getCustomerCommunicationToken()
            }
        }
    }
    
    private func getCustomerCommunicationToken () {
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
        NetworkManager.shared.getACSUserDetails(url: fullUrl) { response, error in
            if(error == nil){
                self.acsToken = response.customerUserToken
                self.storageUserDefaults.set(self.acsToken, forKey: StorageKeys.acsToken)
                self.registerIncomingCallPushNotifications()
            }
        }
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
