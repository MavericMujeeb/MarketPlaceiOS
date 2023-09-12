//
//  AzureGraphApiTests.swift
//  CitiAppsTests
//
//  Created by Balaji Babu Modugumudi on 21/08/23.
//

import XCTest
import Foundation

@testable import CitiApps

final class AzureGraphApiTests: XCTestCase {

    var bankerEmailId = ""
    var customerUserName = ""
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testACSParticipantDetailsApi () {
        NetworkManager.shared.getAcsParticipantDetails { participantDetails, error in
            XCTAssert(participantDetails == nil , "ACS participant details api failed")
            XCTAssert(participantDetails?.originator?.participantName == nil || participantDetails?.originator?.participantName == "", "participantName missing in the response")
        }
    }
    
    func testACSUserDetailsApi () {
        
    }
    
}
