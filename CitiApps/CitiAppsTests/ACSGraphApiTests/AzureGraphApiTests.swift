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

    //Currently these values are hardcoded.
    var bankerEmailId = ""
    var customerUserName = ""
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    /*
     * Test azure communication token api response
     */
    func testAzureCommunicationTokenApi () throws {
        NetworkManager.shared.getAcsUserDetails { participantDetails, error in
            print(participantDetails?.originator?.participantName)
            
            XCTAssert(participantDetails == nil , "ACS participant details api failed")
            XCTAssert(participantDetails?.originator?.participantName == nil || participantDetails?.originator?.participantName == "", "participantName missing in the response")
        }
    }
    
    /*
     * Test azure communication user details api response
     * This api will return the ACS user id and communication token for requested users.
     */
    func testAzureUserDetailsApi () throws {
        
    }
}
