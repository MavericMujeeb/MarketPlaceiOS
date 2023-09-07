//
//  FlutterEngineTests.swift
//  CitiAppsTests
//
//  Created by Balaji Babu Modugumudi on 31/08/23.
//

import XCTest
@testable import CitiApps

final class FlutterEngineTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_flutter_engine() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        XCTAssertTrue(appDelegate.controller != nil, "Flutter view controller with flutter engine failed initialization failed")
    }
}
