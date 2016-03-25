//
//  PubNubHistory.swift
//  Pods
//
//  Created by Terry on 3/24/16.
//
//

import Foundation
import PubNub

public extension PubNub {

    /**
     Download messages from now to earlier in time, until limit is reached, reached a certain point in time,
     or end of channel history is reached.

     - parameter inChannel: channel name to download message from
     - parameter limit:     maximum number of messages to download
     - parameter asOldAs:   oldest message at which to stop download
     */
    public func downloadLatestMessages(inChannel: String, limit: Int, asOldAs: NSNumber? = nil, pageSize: Int? = 100, completion: ([[String:AnyObject]], PNErrorStatus?) -> Void) {

        let PUBNUB_LIMIT = (pageSize ?? 0) > 100 || (pageSize ?? 0) < 0 ? 100 : (pageSize ?? 100)

        // Result
        var results: [[[String:AnyObject]]] = []
        var total: Int = 0

        func enforceResults() -> [[String:AnyObject]] {
            // clean up messages older than given timestamp or beyond the limit
            let flattened = Array(results.flatten()).filter { dict in
                if let tk = dict["timetoken"] as? NSNumber {
                    // only return results newer than the cut off time
                    return tk.longLongValue >= asOldAs?.longLongValue
                }
                return false
            }
            // return all we have if limit is not reached
            if flattened.count <= limit {
                return flattened
            }
            // since messages are ordered from oldest to newest, we take x elements from the end of the array.
            return Array(flattened[(flattened.count - limit)..<flattened.count])
        }

        func downloadMessages(start: NSNumber) {
            // Load messages from newest to oldest
            self.historyForChannel(inChannel, start: start, end: nil, limit: UInt(PUBNUB_LIMIT), reverse: false, includeTimeToken: true) { (result, status) -> Void in

                if status != nil {
                    completion(enforceResults(), status)
                    return
                }

                guard let messages = result?.data.messages as? [[String:AnyObject]] else {
                    completion(enforceResults(), status)
                    return
                }

                guard let oldest = result?.data.start else {
                    completion(enforceResults(), status)
                    return
                }

                results.insert(messages, atIndex: 0)
                total += messages.count

                if messages.count < PUBNUB_LIMIT || total >= limit || oldest.longLongValue <= asOldAs?.longLongValue {
                    // We are done
                    completion(enforceResults(), status)
                } else {
                    // Download more
                    downloadMessages(oldest)
                }
            }
        }
        
        downloadMessages(PubNub.currentTimetoken())
    }

    public static func currentTimetoken() -> NSNumber {
        return convertNSDate(NSDate())
    }

    public static func convertNSDate(date: NSDate) -> NSNumber {
        return date.timeIntervalSince1970 * 10_000_000
    }
}

