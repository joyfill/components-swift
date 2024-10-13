Pod::Spec.new do |s|
s.name              = 'Joyfill'
s.version           = '1.1.1'
s.summary           = 'Joyfill is a form solution SDK.'
s.description       = 'Joyfill provides form solutions for mobile apps with easy integration.'
s.homepage          = 'https://github.com/joyfill/components-swift'
s.license           = { :type => 'MIT', :file => 'LICENSE.txt' }
s.author            = { 'Your Name' => 'your.email@example.com' }
s.source            = { :git => 'https://github.com/joyfill/components-swift.git', :branch => 'main' }
  # Specify Swift version
  s.swift_version = '5.0'
s.ios.deployment_target = '15.0'
s.module_name      = 'Joyfill'
# Main framework source files
s.source_files = 'Sources/JoyfillUI/**/*.{swift}'
#s.dependency  'JoyfillModel', "#{s.version}"

 s.subspec 'JoyfillModel' do |ss|
    ss.source_files = 'Sources/JoyfillModelDir/**/*.{swift}'
  end

end
