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


class TeamsCallingController {
    
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
    
    private let busyOverlay = BusyOverlay(frame: .zero)
    
    func startCall() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        self.tokenService = TokenService(tokenACS:"", communicationTokenFetchUrl: "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/", getAuthTokenFunction: { () -> String? in
            return appDelegate.authHandler.authToken
        })
        Task{
            do{
                await self.joinCall()
            }
        }
    }
    
    func startAudioVideoCall(isVideoCall : Bool = false) {
        self.callParticipantDetailsAPI(isVideoCall: isVideoCall)
    }
    
    func callParticipantDetailsAPI(isVideoCall : Bool) {
        CircleLoader.sharedInstance.show()
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
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = reqBody.data(using: .utf8)!
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            CircleLoader.sharedInstance.hide()
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ParticipantDetails.self, from: data)
                    self.bankerUserName = responseModel.originator?.participantName
                    self.bankerAcsId = responseModel.originator?.acsId
                    ACSResources.bankerAcsId = self.bankerAcsId
                    
                    self.custUserName = responseModel.participantList?[0].participantName
                    self.custAcsId = responseModel.participantList?[0].acsId
                    DispatchQueue.main.async {
                        self.startCall(isVideoCall: isVideoCall)
                    }
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
    
    func startCall(isVideoCall : Bool) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        CircleLoader.sharedInstance.show()
        let fullUrl: String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+self.bankerAcsId+"&customerAcsId="+self.custAcsId
       
        self.tokenService = TokenService(tokenACS:"", communicationTokenFetchUrl: fullUrl, getAuthTokenFunction: { () -> String? in
           
            return appDelegate.authHandler.authToken
        })
        Task{
            do{
                await self.startAudioCall(acsId: self.bankerAcsId, isVideoCall: isVideoCall)
                CircleLoader.sharedInstance.hide()
            }
        }
    }
    
    func startAudioCall(acsId:String,isVideoCall : Bool = false) async {
        print("\(#function):\(isVideoCall)")
        let isAudioCall = isVideoCall ? false : true
        let displayName =  users[loggedInUser]?["name"]  ?? ""
        let callConfig = JoinCallConfig(joinId: acsId, displayName: displayName, callType: .voiceCall, isAudioCall: isAudioCall, isVideoCall: isVideoCall)
        self.callingContext = CallingContext(tokenFetcher: self.tokenService.getCustomerCommunicationToken)
        self.callingContext.displayName = displayName
        self.callingContext.userId = userid
        await self.callingContext.startCallComposite(callConfig)
    }
    
    func joinCall() async {
        let displayName =  users[loggedInUser]?["name"]  ?? ""
        let callConfig = JoinCallConfig(joinId: teamsLink, displayName: displayName, callType: .teamsMeeting, isAudioCall: false, isVideoCall: false)
        self.callingContext = CallingContext(tokenFetcher: self.tokenService.getCommunicationToken)
        self.callingContext.displayName = displayName
        self.callingContext.userId = userid
        await self.callingContext.startCallComposite(callConfig)
    }
}
