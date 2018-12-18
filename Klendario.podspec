
Pod::Spec.new do |s|

  s.name             = 'Klendario'
  s.version          = File.read('VERSION')
  s.summary          = 'A Swift wrapper over the EventKit framework'
  s.description      = <<-DESC
Klendario is a Swift wrapper over the EventKit framework. It adds simplicity to the task of managing events in the iOS Calendar by providing handfull functions, extensions and the semi-automatic managment of the user authorization request to access the iOS calendar.
                       DESC

  s.homepage         = 'https://github.com/thxou/Klendario'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thxou' => 'yo@thxou.com' }
  s.source           = { :git => 'https://github.com/thxou/Klendario.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/thxou'

  s.ios.deployment_target = '9.0'
  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Source/*.swift'

end
