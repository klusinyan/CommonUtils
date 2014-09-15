Pod::Spec.new do |s|
  s.name         = 'CommonUtils'
  s.version      = '1.0.2'
  s.summary      = 'Common Utilities.'
  s.homepage     = 'https://git.sftc.it/softec-ios/libcommonutils'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Karen Lusinyan' => 'karen.lusinyan@softecspa.it' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'git@git.sftc.it:softec-ios/libcommonutils.git', :tag => s.version.to_s }

  s.prefix_header_file = 'CommonUtils/Classes/Lib-Prefix.pch'

  non_arc_files  = 'CommonUtils/Classes/Categories/NSString/GTMNSString+HTML.{h,m}',
                   'CommonUtils/Classes/Categories/NSString/NSString+HTML.{h,m}'

  s.requires_arc = true
  s.source_files = 'CommonUtils/Classes/**/*.{h,m}'
  s.exclude_files = non_arc_files
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  s.dependency 'AFNetworking', '~> 1.3.3'

  s.resource_bundle = { 'CommonUtils' => 'CommonUtils/Resources/*.*' }
  #s.resources = 'CommonUtils/Resources/xib/*.{xib}'

end