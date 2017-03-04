Pod::Spec.new do |s|
s.name             = 'SwiftySignals'
  s.version          = '3.0.3'
  s.summary          = 'SwiftySignals provides a simple API to send and react to application messages.'
  s.description      = <<-DESC
SwiftySignals provides a simple API to send and react to application messages.
There are three concept involved: Signals, Messages and Slots. 
Signals are senders of messages (arbitrary type). Slots receive messages in the first place and hand them over to a connected user defined function. The concept can be considered as a specific implementation of the observer pattern.
  DESC

  s.homepage         = 'https://github.com/psturm-swift/SwiftySignals'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Patrick Sturm' => 'psturm.mail@googlemail.com' }
  s.source           = { :git => 'https://github.com/psturm-swift/SwiftySignals.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/psturm_swift'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'Sources/*.swift'

  s.requires_arc = true
end
