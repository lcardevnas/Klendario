#
# Be sure to run `pod lib lint Klendario.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Klendario'
  s.version          = File.read('VERSION')
  s.summary          = 'A Swift wrapper over the EventKit framework'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Klendario is a Swift wrapper over the EventKit framework. It adds simplicity to the task of managing events in the iOS Calendar by providing handfull functions, extensions and the semi-automatic managment of the user authorization request to access the iOS calendar.
                       DESC

  s.homepage         = 'https://github.com/thxou/Klendario'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thxou' => 'yo@thxou.com' }
  s.source           = { :git => 'https://github.com/thxou/Klendario.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Source/**/*'
  
  # s.resource_bundles = {
  #   'Klendario' => ['Klendario/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
