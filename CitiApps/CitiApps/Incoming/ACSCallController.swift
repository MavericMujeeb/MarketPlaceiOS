//
//  ACSCallController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 31/07/23.
//

import Foundation
import UIKit


class ACSCallController {
    
    var appPubs:AppPubs
    var acsToken:String = ""
    var tokenService: TokenService!
    let storageUserDefaults = UserDefaults.standard
    var callingContext: CallingContext!
    
    init(appPubs: AppPubs) {
        self.appPubs = appPubs
    }
    
    func startCallComposite() {
        
    }
    
    func startCall(isVideoCall : Bool) {
        let token = storageUserDefaults.value(forKeyPath: StorageKeys.acsToken) as! String
        self.acsToken = token
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        CircleLoader.sharedInstance.show()
        
        self.tokenService = TokenService(tokenACS: self.acsToken, communicationTokenFetchUrl: "", getAuthTokenFunction: { () -> String? in
            return appDelegate.authHandler.authToken
        })
        
        Task{
            do {
                await self.startAudioCall(acsId: "", isVideoCall: isVideoCall)
                CircleLoader.sharedInstance.hide()
            }
        }
    }
    
    func startAudioCall(acsId:String, isVideoCall : Bool = false) async {
        let isAudioCall = isVideoCall ? false : true
        let displayName =  users[loggedInUser]?["name"]  ?? ""
        let callConfig = JoinCallConfig(joinId: acsId, displayName: displayName, callType: .voiceCall, isAudioCall: isAudioCall, isVideoCall: isVideoCall, isIncomingCall: true)
        self.callingContext = CallingContext(tokenFetcher: self.tokenService.getCustomerCommunicationToken)
        self.callingContext.userId = ""
        self.callingContext.displayName = displayName
        await self.callingContext.startCallComposite(callConfig)
    }
}
