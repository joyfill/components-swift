Pod::Spec.new do |s|
  s.name              = 'Joyfill'
  s.version           = '1.1.1'
  s.summary           = 'Joyfill is a form solution SDK that integrates JoyfillModel.'
  s.description       = 'Joyfill provides form solutions for mobile apps with easy integration, leveraging the capabilities of JoyfillModel.'
  s.homepage          = 'https://github.com/joyfill/components-swift'
  s.license           = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author            = { 'Your Name' => 'your.email@example.com' }
  s.source            = { :git => 'https://github.com/joyfill/components-swift.git', :branch => 'main' }
  s.swift_version     = '5.0'
  s.ios.deployment_target = '15.0'
  s.module_name       = 'Joyfill'

  # Main framework source files
  s.source_files       = 'Sources/JoyfillUI/**/*.{swift}'
  
  # Dependencies
  s.dependency 'JoyfillModel', '~> 1.1.1'
end