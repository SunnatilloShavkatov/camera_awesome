#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint camera_awesome.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'camera_awesome'
  s.version          = '1.0.0'
  s.summary          = 'An open source camera plugin by the community for the community'
  s.description      = <<-DESC
An open source camera plugin by the community for the community
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'JPSVolumeButtonHandler'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

end
