#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fk_user_agent.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_wni'
  s.version          = '1.0.0'
  s.summary          = 'Flutter WNInterface Plugin'
  s.description      = <<-DESC
Flutter WNInterface Plugin
                       DESC
  s.homepage         = 'https://github.com/progdesigner/flutter_wni'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'progdesigner' => 'me@progdesigner.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
