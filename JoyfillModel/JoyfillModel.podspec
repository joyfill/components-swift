Pod::Spec.new do |spec|
  spec.name         = 'JoyfillModel'
  spec.version      = '1.0.6' 
  spec.summary      = 'Joyfill model'
  spec.description  = <<-DESC
    Joyfill provides you with ready-to-use embeddable UI SDKs, APIs, and Services that empower you to add powerful Form and PDF capabilities directly inside your own application on web and mobile.
  DESC
  spec.homepage     = 'https://github.com/joyfill/components-swift'
  spec.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  spec.author       = { 'Vishnu Dutt' => 'vishnubishnoi7@gmail.com' }
  spec.source       = { :git => 'https://github.com/joyfill/components-swift.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '15.0' # Adjust according to your target
  spec.swift_version = '5.0'          # Specify the Swift version

  # Source files
  spec.source_files = 'aa/*.{swift}' # Assuming your files are in 'Sources'
  spec.exclude_files = 'Tests'               # Exclude test files if necessary
end
