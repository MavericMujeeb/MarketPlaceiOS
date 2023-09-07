//
//  GraphApiTests.swift
//  CitiAppsTests
//
//  Created by Balaji Babu Modugumudi on 24/08/23.
//

import XCTest
@testable import CitiApps

final class GraphApiTests: XCTestCase {

    override func setUp() {
        
        let bankerEmailId = UserDefaults.standard.string(forKey: StorageKeys.bankerEmailId) ?? ACSResources.bankerUserEmail
        let customerUserName = UserDefaults.standard.string(forKey: StorageKeys.loginUserName) ?? ACSResources.customerUserName
        
     
        UserDefaults.standard.setValue(bankerEmailId, forKey: StorageKeys.bankerEmailId)
        UserDefaults.standard.setValue(customerUserName, forKey: StorageKeys.loginUserName)
        
        super.setUp()
    }

    override func tearDown()  {
        super.tearDown()
    }
    
    func test_acs_userdetails_graph_api () {
        NetworkManager.shared.getAcsUserDetails { participantDetails, error in
            XCTAssert(error != nil, "ACS details api has error response")
            XCTAssert(participantDetails! as ParticipantDetails == nil, "ACS details api has valid response")
            
            if(participantDetails != nil){
                XCTAssert(participantDetails?.originator?.participantName == nil || participantDetails?.originator?.participantName == "", "ACS details api response Participant Name is empty")
                XCTAssert(participantDetails?.originator?.participantName == nil || participantDetails?.originator?.acsId == "", "ACS ID of banker is empty")
            }
        }
    }
    
    func test_acs_communication_token_api () {
//        NetworkManager.shared.getAzureCommunicationToken(token: "")
    }
}
