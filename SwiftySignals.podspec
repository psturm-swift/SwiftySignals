#
# Be sure to run `pod lib lint SwiftySignals.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftySignals'
  s.version          = '1.3.0'
  s.summary          = 'SwiftySignals provides a simple API to send and react to application messages.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SwiftySignals provides a simple API to send and react to application messages.
There are three concept involved: Signals, Messages and Slots. 
Signals are senders of messages (arbitrary type). Slots receive messages in the first place and hand them over to a connected user defined function. The concept can be considered as a specific implementation of the observer pattern.
  DESC

  s.homepage         = 'https://github.com/psturm-swift/SwiftySignals'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Patrick Sturm' => 'psturm.mail@googlemail.com' }
  s.source           = { :git => 'https://github.com/psturm-swift/SwiftySignals.git', :tag => s.version.to_s }
 s.social_media_url = 'https://twitter.com/psturm_swift'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'SwiftySignals/*.swift'
end
