//
//  TeamsCallingController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 24/08/23.
//

import Foundation
import FluentUI
import UIKit
import PIPKit

class AzureCallController {
    
    var callingContext: CallingContext!
    var tokenService: TokenService!
    var teamsLink: String!
    var bankerAcsId:String! = ""
    var bankerUserToken:String! = ""
    var bankerEmailId:String! = ""
    var bankerUserName:String! = ""
    var custAcsId:String! = ""
    var custUserToken:String! = ""
    var custUserName:String! = ""
    
    
    /*
     * Function to init token service for Scheduled meeting call / adhoc audio video call
     * Pass the required url as param
     */
    func initTokenService (url:String) {
        self.tokenService = TokenService(tokenACS:"", communicationTokenFetchUrl: url, getAuthTokenFunction: { () -> String? in
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            return appDelegate.authHandler.authToken
        })
    }
    
    
    
    
    func joinTeamsCall() async {
        initTokenService(url: "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/")
        
        let displayName =  users[loggedInUser]?["name"]  ?? ""
        let callConfig = JoinCallConfig(joinId: teamsLink, displayName: displayName, callType: .teamsMeeting, isAudioCall: false, isVideoCall: false)
        self.callingContext = CallingContext(tokenFetcher: self.tokenService.getCommunicationToken)
        self.callingContext.displayName = displayName
        self.callingContext.userId = userid
        
        //Start Azure UI Call with Teams call config.
        await self.callingContext.startCallComposite(callConfig)
    }
    
    func startAudioVideoCall(isVideoCall : Bool = false) {
        CircleLoader.sharedInstance.show()
        
        fetchACSDetails { acsDetails, error in
            
            CircleLoader.sharedInstance.hide()
            if(error == nil){
                self.bankerUserName = acsDetails?.originator?.participantName
                self.bankerAcsId = acsDetails?.originator?.acsId
                self.custUserName = acsDetails?.participantList?[0].participantName
                self.custAcsId = acsDetails?.participantList?[0].acsId
                ACSResources.bankerAcsId = self.bankerAcsId
                
                DispatchQueue.main.async {
                    self.startAdhocACSCall(isVideoCall: isVideoCall)
                }
            }
        }
    }
    
    
    func fetchACSDetails (completion: @escaping (ParticipantDetails?, Error?)->Void) {
        let storageUserDefaults = UserDefaults.standard
        self.bankerEmailId = storageUserDefaults.string(forKey: "bankerEmailId")
        self.custUserName = storageUserDefaults.string(forKey: "loginUserName")
        let reqBody = "{" +
        "\"originatorId\":\"\(self.bankerEmailId!)\"," +
        "\"participantName\":\"\(self.custUserName!)\"" +
        "}"
        
        let fullUrl: String = ACSResources.acs_chat_participantdetails_api
        
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        NetworkManager.shared.getAcsParticipantDetails { details, error in
            if(error == nil){
                completion(details, nil)
            }
        }
    }
    
    /*
     * Function to configure ACS details to start Adhoc audio/video call
     */
    
    func startAdhocACSCall(isVideoCall : Bool) {
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
        initTokenService(url: fullUrl)
        Task{
            do{
                await self.startAudioVideoCall(acsId: self.bankerAcsId, isVideoCall: isVideoCall)
                CircleLoader.sharedInstance.hide()
            }
        }
    }
    
    /*
     * Function to start Adhoc audio/video call
     */
    func startAudioVideoCall(acsId:String,isVideoCall : Bool = false) async {
        let isAudioCall = isVideoCall ? false : true
        let displayName =  users[loggedInUser]?["name"]  ?? ""
        let callConfig = JoinCallConfig(joinId: acsId, displayName: displayName, callType: .voiceCall, isAudioCall: isAudioCall, isVideoCall: isVideoCall)
        self.callingContext = CallingContext(tokenFetcher: self.tokenService.getCustomerCommunicationToken)
        self.callingContext.displayName = displayName
        self.callingContext.userId = userid
        await self.callingContext.startCallComposite(callConfig)
    }
}
