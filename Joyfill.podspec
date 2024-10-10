Pod::Spec.new do |s|
  s.name              = 'Joyfill'
  s.version           = '1.0.6'
  s.summary           = 'Joyfill is a form solution SDK.'
  s.description       = 'Joyfill provides form solutions for mobile apps with easy integration.'
  s.homepage          = 'https://github.com/joyfill/components-swift'
  s.license           = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author            = { 'Your Name' => 'your.email@example.com' }
  s.source            = { :git => 'https://github.com/joyfill/components-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'

  # Main framework source files
  s.source_files = 'Sources/Joyfill/**/*.{swift}'

  # Subspec for JoyfillModel
  s.subspec 'JoyfillModel' do |ss|
    ss.source_files = 'Sources/JoyfillModel/*.swift'
  end
end