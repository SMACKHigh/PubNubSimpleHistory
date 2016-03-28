# PubNubSimpleHistory

[![CI Status](http://img.shields.io/travis/Terry Xu/PubNubSimpleHistory.svg?style=flat)](https://travis-ci.org/Terry Xu/PubNubSimpleHistory)
[![Version](https://img.shields.io/cocoapods/v/PubNubSimpleHistory.svg?style=flat)](http://cocoapods.org/pods/PubNubSimpleHistory)
[![License](https://img.shields.io/cocoapods/l/PubNubSimpleHistory.svg?style=flat)](http://cocoapods.org/pods/PubNubSimpleHistory)
[![Platform](https://img.shields.io/cocoapods/p/PubNubSimpleHistory.svg?style=flat)](http://cocoapods.org/pods/PubNubSimpleHistory)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Methods

Download messages from **now** backward in time, until limit is reached or end of channel history is reached. Messages are returned in chronological order (oldest to newest). Useful to get latest messages in a channel.

```
public func downloadLatestMessages(inChannel: String, 
	limit: Int, 
	pageSize: Int? = default, 
	completion: ([[String : AnyObject]], PNErrorStatus?) -> Void)
```

Download messages from **now** backward in time, until limit is reached, reached a certain point in time, or end of channel history is reached. Messages are returned in chronological order (oldest to newest). Useful to get latest messages in a channel where messages beyond a certain age are no longer valuable.

```
public func downloadLatestMessagesNewerThan(inChannel: String, 
	limit: Int?, 
	newerThan: NSNumber? = default, 
	pageSize: Int? = default, 
	completion: ([[String : AnyObject]], PNErrorStatus?) -> Void)
```

Download messages from a given timetoken backward in time, until the limit is reached or end of channel history is reached. Messages are returned in chronological order (oldest to newest). Useful to get older messages from a known time, e.g. pagination.

```
public func downloadMessagesOlderThan(inChannel: String,
	limit: Int, 
	olderThan: NSNumber, 
	pageSize: Int? = default, 
	completion: ([[String : AnyObject]], PNErrorStatus?) -> Void)
```

## Requirements

## Installation

PubNubSimpleHistory is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PubNubSimpleHistory"
```

## Author

Terry Xu [@coolnalu](https://twitter.com/coolnalu)

Kevin Flynn [@KevinMarkFlynn](https://twitter.com/KevinMarkFlynn)

## License

PubNubSimpleHistory is available under the MIT license. See the LICENSE file for more info.
