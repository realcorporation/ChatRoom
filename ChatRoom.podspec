#
# Be sure to run `pod lib lint SimpleTransition.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ChatRoom"
  s.version          = "0.6.1"
  s.summary          = "iOS ChatRoom."
  s.description      = "A material ChatRoom."
  s.homepage         = "https://github.com/realcorporation/ChatRoom"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Mingloan" => "mingloanchan@gmail.com" }
  s.source           = { :git => "https://github.com/realcorporation/ChatRoom.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mingloan'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'ChatRoom/*'
  s.dependency "NextGrowingTextView"

end
