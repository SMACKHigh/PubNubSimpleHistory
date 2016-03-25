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
     or end of message history is reached.

     - parameter inChannel: channel name to download message from
     - parameter limit:     maximum number of messages to download
     - parameter asOldAs:   oldest message at which to stop download
     */
    public func downloadLatestMessages(inChannel: String, limit: UInt, asOldAs: NSNumber?, completion: ([[String:AnyObject]], PNErrorStatus?) -> Void!) {

        let PUBNUB_LIMIT: UInt = 100

        // Result
        var results: [[[String:AnyObject]]] = []
        var total: UInt = 0

        func enforceResults() -> [[String:AnyObject]] {
            // clean up messages older than given timestamp or beyond the limit
            return Array(Array(results.flatten())[0..<Int(limit)])
        }

        func downloadMessages(start: NSNumber) {
            // Load messages from newest to oldest
            self.historyForChannel(inChannel, start: start, end: asOldAs, limit: PUBNUB_LIMIT, reverse: false, includeTimeToken: true) { (result, status) -> Void in

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

                results.append(messages)
                total += UInt(messages.count)

                if UInt(messages.count) < PUBNUB_LIMIT || total >= limit || oldest.longLongValue <= asOldAs?.longLongValue {
                    // We are done
                    completion(enforceResults(), status)
                } else {
                    // Download more
                    downloadMessages(oldest)
                }
            }
        }
        
        downloadMessages(NSDate().timeIntervalSince1970 * 10_000_000)
    }
}

