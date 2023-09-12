//
//  AzureCallingTests.swift
//  CitiAppsTests
//
//  Created by Balaji Babu Modugumudi on 21/08/23.
//

import XCTest
import AzureCommunicationCalling
@testable import CitiApps

final class AzureCallingTests: XCTestCase {
    
    var azureCallController : AzureCallController = AzureCallController()
    var incomingCallingController : ACSIncomingCallController = ACSIncomingCallController()
    

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testScheduledMeetingJoinCallUsingTeamsMeetingLink () {
        azureCallController.initTokenService(url: ACSResources.acs_chat_participantdetails_api)
        azureCallController.tokenService.getCommunicationToken { tokenString, error in
            XCTAssertTrue(tokenString?.isEmpty , "Communincation Token is empty")
        }
        
        Task{
            await azureCallController.joinCall()
            XCTAssertTrue(azureCallController.callingContext.displayName.isEmpty , "Teams meeting callingContext displayName is not set")
            XCTAssertTrue(azureCallController.callingContext.callComposite == nil , "Teams meeting callComposite is empty")
            XCTAssertTrue(azureCallController.callingContext.joinId == nil , "Teams meeting link is empty")
            XCTAssertTrue(azureCallController.callingContext.userId == nil , "Logged in user id is empty")
        }
    }
    
    func testAdhocOutgoingAudioCallUsingClientAcsId () {
        azureCallController.fetchACSDetails { participantDetails, error in
            if(error == nil){
            }
            Task {
                await azureCallController.startAudioVideoCall(isVideoCall:false)
            }
        }
        
    }
    
    
    func testAdhocOutgoingVideoCallUsingClientAcsId () {
        
    }
    
  
    func testIncomingCallPushNotificationRegistration() {
        
    }
}
