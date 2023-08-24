//
//  DeeplinkTests.swift
//  CitiAppsTests
//
//  Created by Balaji Babu Modugumudi on 21/08/23.
//

import XCTest

final class DeeplinkTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown()  {
        super.tearDown()
    }

    func testScheduledMeetingDeeplinkUrl() {
        let deepLinkUrl = MockData.deeplinkMeetingUrl
        let urlComponents = URLComponents(string: deepLinkUrl)
        
        let host = urlComponents?.host
        let queryItems = urlComponents?.queryItems
        let meetingLink = queryItems?.first(where: { $0.name == "meetingURL" })?.value

        XCTAssert(host != nil, "Host is nil")
        XCTAssert(meetingLink != nil, "Teams meeting link not found")
    }
    
    func getThreadId(from meetingLink: String) -> String? {
        let decodedLink = meetingLink.htmlDecoded
        
        if let range = decodedLink.range(of: "meetup-join/") {
            let thread = decodedLink[range.upperBound...]
            if let endRange = thread.range(of: "/")?.lowerBound {
                var threadId = String(thread.prefix(upTo: endRange))
                threadId = threadId.replacingOccurrences(of: "%3a", with: ":").replacingOccurrences(of: "%3A", with: ":").replacingOccurrences(of: "%40", with: "@")
                return threadId
            }
        }
        return nil
    }
    
    
    func testScheduledMeetingThreadId () {
        let deepLinkUrl = MockData.deeplinkMeetingUrl
        let urlComponents = URLComponents(string: deepLinkUrl)
        
        let queryItems = urlComponents?.queryItems
        let meetingLink = queryItems?.first(where: { $0.name == "meetingURL" })?.value
        
        let threaId = getThreadId(from: meetingLink!)
        XCTAssert(threaId != nil, "Thread id not found in meeting link")
    }

}


extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}

