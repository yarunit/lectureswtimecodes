Pod::Spec.new do |s|
  s.name             = 'whisper_kit'
  s.version          = '0.0.1'
  s.summary          = 'Stand-in so the iPhone project can build and record.'
  s.homepage         = 'https://github.com/yarunit/lectureswtimecodes'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Lectures' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/WhisperKitPlugin.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
