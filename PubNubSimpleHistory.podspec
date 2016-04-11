Pod::Spec.new do |s|

  s.name             = "PubNubSimpleHistory"
  s.version          = "0.1.1"
  s.summary          = "An easier-to-understand extension for PubNub history API"
  s.description      = <<-DESC
    PubNub history API is a bit hard to wrap head around. We\'ve added some convenient methods to make it easier to use.
  DESC
  s.homepage         = "https://github.com/SMACKHigh/PubNubSimpleHistory"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Terry Xu" => "https://twitter.com/coolnalu", "Kevin Flynn" => "https://twitter.com/KevinMarkFlynn" }
  s.source           = { :git => "https://github.com/SMACKHigh/PubNubSimpleHistory.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/coolnalu'
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
  s.dependency 'PubNub'

end
