Pod::Spec.new do |s|
  s.name              = 'Joyfill'
  s.version           = '1.2.0'
  s.summary           = 'Joyfill is a form solution SDK that integrates JoyfillModel.'
  s.description       = 'Joyfill provides form solutions for mobile apps with easy integration, leveraging the capabilities of JoyfillModel.'
  s.homepage          = 'https://github.com/joyfill/components-swift'
  s.license           = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author            = { 'Vishnu Dutt' => 'vishnubishnoi7@gmail.com' }
  s.source            = { :git => 'https://github.com/joyfill/components-swift.git', :tag => s.version.to_s }
  s.swift_version     = '5.0'
  s.ios.deployment_target = '15.0'
  s.module_name       = 'Joyfill'

  # Main framework source files
  s.source_files       = 'Sources/JoyfillUI/**/*.{swift}'
  
  # Dependencies
  s.dependency 'JoyfillModel', '~> 1.0.8'
end