import UIKit
import XCTest
import PubNub
import PubNubSimpleHistory

class Tests: XCTestCase {

    lazy var configuration: PNConfiguration = {
        let lazyConfig = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        return lazyConfig
    }()

    lazy var client: PubNub = {
        return PubNub.clientWithConfiguration(self.configuration)
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDownloadLatestMessages() {
        let expect = expectationWithDescription("Download messages")
        let limit = 623
        client.downloadLatestMessages(channelId, limit: limit) { messages, status in
            XCTAssertEqual(messages.count, 623)

            var previousTK = (messages.first?["timetoken"] as! NSNumber).longLongValue

            // make sure messages are sorted from oldest to newest
            for message in messages {
                let tk = (message["timetoken"] as! NSNumber).longLongValue
                XCTAssertGreaterThanOrEqual(tk, previousTK)
                previousTK = tk
            }
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(60, handler: nil)
    }

    func testDownloadLatestMessagesNewerThan() {
        let expect = expectationWithDescription("Download messages")
        let limit = 1744
        let threeDaysAgo = NSDate().dateByAddingTimeInterval(-3 * 24 * 60 * 60)
        client.downloadLatestMessagesNewerThan(channelId, limit: limit, newerThan: PubNub.convertNSDate(threeDaysAgo)) { messages, status in
            XCTAssertGreaterThan(messages.count, 0)
            XCTAssertLessThanOrEqual(messages.count, 2744)

            var previousTK = (messages.first?["timetoken"] as! NSNumber).longLongValue

            // make sure the first message is newer than or equal to the cut off time
            XCTAssertGreaterThanOrEqual(previousTK, PubNub.convertNSDate(threeDaysAgo).longLongValue)

            // make sure messages are sorted from oldest to newest
            for message in messages {
                let tk = (message["timetoken"] as! NSNumber).longLongValue
                XCTAssertGreaterThanOrEqual(tk, previousTK)
                previousTK = tk
            }
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(60, handler: nil)
    }

    func testDownloadMessagesOlderThan() {
        let expect = expectationWithDescription("Download messages")
        let limit = 839
        let threeDaysAgo = NSDate().dateByAddingTimeInterval(-3 * 24 * 60 * 60)
        client.downloadMessagesOlderThan(channelId, limit: limit, olderThan: PubNub.convertNSDate(threeDaysAgo)) { messages, status in
            XCTAssertEqual(messages.count, 839)

            var previousTK = (messages.first?["timetoken"] as! NSNumber).longLongValue

            // make sure messages are sorted from oldest to newest
            for message in messages {
                let tk = (message["timetoken"] as! NSNumber).longLongValue
                XCTAssertGreaterThanOrEqual(tk, previousTK)
                previousTK = tk
            }

            // make sure the last message is older than or equal to the begin time
            XCTAssertLessThanOrEqual(previousTK, PubNub.convertNSDate(threeDaysAgo).longLongValue)

            expect.fulfill()
        }
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
}
