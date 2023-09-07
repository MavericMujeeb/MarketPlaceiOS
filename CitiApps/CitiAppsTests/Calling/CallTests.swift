//
//  callTests.swift
//  CitiAppsTests
//
//  Created by Balaji Babu Modugumudi on 30/08/23.
//

import XCTest
@testable import CitiApps
@testable import AzureCommunicationUICalling

import AzureCommunicationCommon
 
final class CallTests: XCTestCase {

    var tokenCredential:CommunicationTokenCredential?
    
    override func setUp()  {
        loggedInUser = "veronicastephens838@gmail.com"
        userid  = "fc123292-abe0-4629-982e-1cfe16759cbb"
        
        UserDefaults.standard.setValue(ACSResources.bankerUserEmail, forKey: "bankerEmailId")
        UserDefaults.standard.setValue(ACSResources.customerUserName, forKey: "loginUserName")

        super.setUp()
    }

    override func tearDown()  {
        super.tearDown()
    }
    
    
    @MainActor
    func test_join_teams_call () async {
        let teamsLink = MockDataTest.teamsMeetingLinkUrl
        let teamsCallingViewController = TeamsCallingViewController()
        
        teamsCallingViewController.teamsLink = teamsLink
        UserDefaults.standard.set("", forKey: StorageKeys.bankerEmailId)
        
        teamsCallingViewController.initTokenService()
        XCTAssertTrue(teamsCallingViewController.tokenService != nil, "Token service is not initialized")
        await teamsCallingViewController.joinCall()

        XCTAssertTrue(teamsCallingViewController.callingContext != nil ,"Calling Context creation failed for scheduled teams meeting join action.")
        XCTAssertTrue(teamsCallingViewController.callingContext.userId != nil, "ACS usedid of loggedin user is not set.")
        XCTAssertTrue(teamsCallingViewController.callingContext.displayName != nil, "Teams meeting user display name is not set.")
        
        do{
            let credentials = try await teamsCallingViewController.callingContext.getTokenCredential()
            credentials.token { tkn, err in
                XCTAssertTrue(tkn != nil, "callingContext tokenCredential commuincation token is emtpy")
            }
        }
        catch{
            print("exception - setting communication token credential")
        }
    }
    
    
}
