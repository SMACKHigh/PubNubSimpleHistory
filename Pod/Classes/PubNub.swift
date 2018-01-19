//
//  PubNubHistory.swift
//  Pods
//
//  Created by Terry on 3/24/16.
//
//

import Foundation
import PubNub

let PubNubSimpleHistoryQueue = DispatchQueue(label: "com.smackhigh.pubnub")

public extension PubNub {

    /**
     Download messages from **now** to earlier in time, until limit is reached
     or end of channel history is reached.

     - parameter inChannel:  required channel name to download message from
     - parameter limit:      required maximum number of messages to download
     - parameter newerThan:  optional oldest timetoken at which to stop download
     - parameter pageSize:   optional how many messages to download per request, maximum is 100
     - parameter completion: required result handler, if any errors occurred PNErrorStatus will be set
     */
    public func downloadLatestMessages(inChannel: String, limit: Int, pageSize: Int? = 100, completion: ([[String:AnyObject]], PNErrorStatus?) -> Void) {
        downloadMessages(inChannel, limit: limit, newerThan: nil, olderThan: nil, pageSize: pageSize, completion: completion)
    }

    /**
     Download messages from **now** to earlier in time, until limit is reached, reached a certain point in time,
     or end of channel history is reached.

     - parameter inChannel:  required channel name to download message from
     - parameter limit:      optional maximum number of messages to download
     - parameter newerThan:  optional oldest timetoken at which to stop download
     - parameter pageSize:   optional how many messages to download per request, maximum is 100
     - parameter completion: required result handler, if any errors occurred PNErrorStatus will be set
     */
    public func downloadLatestMessagesNewerThan(inChannel: String, limit: Int?, newerThan: NSNumber? = nil, pageSize: Int? = 100, completion: ([[String:AnyObject]], PNErrorStatus?) -> Void) {
        downloadMessages(inChannel, limit: limit ?? Int.max, newerThan: newerThan, olderThan: nil, pageSize: pageSize, completion: completion)
    }

    /**
     Download messages from a given timetoken to earlier in time, until the limit is reached
     or end of channel history is reached

     - parameter inChannel:  required channel name to download message from
     - parameter limit:      required maximum number of messages to download
     - parameter olderThan:  required timetoken older than which message download will begin
     - parameter pageSize:   optional how many messages to download per request, maximum is 100
     - parameter completion: required result handler, if any errors occurred PNErrorStatus will be set
     */
    public func downloadMessagesOlderThan(inChannel: String, limit: Int, olderThan: Double, pageSize: Int? = 100, completion: ([[String:AnyObject]], PNErrorStatus?) -> Void) {

        downloadMessages(inChannel, limit: limit, newerThan: nil, olderThan: olderThan, pageSize: pageSize, completion: completion)
    }

    func downloadMessages(_ inChannel: String, limit: Int, newerThan: NSNumber? = nil, olderThan: Double? = nil, pageSize: Int? = 100, completion: ([[String:AnyObject]], PNErrorStatus?) -> Void) {

        let PUBNUB_LIMIT = (pageSize ?? 0) > 100 || (pageSize ?? 0) < 0 ? 100 : (pageSize ?? 100)

        // Result
        var results: [[[String:AnyObject]]] = []
        var total: Int = 0

        func finish(_ status: PNErrorStatus?) {
            self.queue {
                // clean up messages older than given timestamp or beyond the limit
                var flattened = Array(results.joined())

                // if cutoff date is specified, filter results
                if let newerThan = newerThan {
                    flattened = flattened.filter { dict in
                        if let tk = dict["timetoken"] as? NSNumber {
                            // only return results newer than the cut off time
                            return tk.int64Value >= newerThan.int64Value
                        }
                        return false
                    }
                }

                // since messages are ordered from oldest to newest, we take x elements from the end of the array.
                if flattened.count > limit {
                    flattened = Array(flattened[(flattened.count - limit)..<flattened.count])
                }

                PubNubSimpleHistoryQueue.async { () -> Void in
                    completion(flattened, status)
                 }
            }
        }

        func downloadMessages(_ olderThan: Double) {
            // Load messages from newest to oldest
            self.historyForChannel(inChannel, start: NSNumber(value: olderThan), end: nil, limit: UInt(PUBNUB_LIMIT), reverse: false, includeTimeToken: true) { (result, status) -> Void in

                if status != nil {
                    finish(status)
                    return
                }

                guard let messages = result?.data.messages as? [[String:AnyObject]] else {
                    finish(status)
                    return
                }

                guard let oldest = result?.data.start else {
                    finish(status)
                    return
                }

                results.insert(messages, at: 0)
                total += messages.count

                if messages.count < PUBNUB_LIMIT || total >= limit || oldest.longLongValue <= newerThan?.int64Value? {
                    // We are done
                    finish(status)
                } else {
                    // Download older messages from the oldest message in this batch
                    downloadMessages(Double(truncating: oldest))
                }
            }
        }
        
        downloadMessages(olderThan ?? PubNub.currentTimetoken())
    }

    public static func currentTimetoken() -> Double {
        return Date().timeIntervalSince1970
    }

    func queue(block: @escaping() -> ()) {
        PubNubSimpleHistoryQueue.async(execute: block)
    }
}

