Pod::Spec.new do |s|
  s.name         = 'CommonUtils'
  s.version      = '1.0.0-beta3'
  s.summary      = 'Common Utilities.'
  s.homepage     = 'https://git.sftc.it/softec-ios/libcommonutils'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Karen Lusinyan' => 'karen.lusinyan@softecspa.it' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'git@git.sftc.it:softec-ios/libcommonutils.git', :tag => s.version.to_s }

  s.prefix_header_file = 'CommonUtils/Classes/Lib-Prefix.pch'

  non_arc_files  = 'CommonUtils/Classes/Categories/NSString/GTMNSString+HTML.m',
                   'CommonUtils/Classes/Categories/NSString/NSString+HTML.m'

  s.subspec 'src' do |ss|
    ss.source_files = 'CommonUtils/Classes/**/*.{h,m}'
    ss.requires_arc = true
  end

  s.exclude_files = non_arc_files

  s.subspec 'no-arc' do |ss|
    ss.requires_arc = false
    ss.source_files = non_arc_files
  end

  s.dependency 'AFNetworking', '~> 1.3.3'

  s.resource_bundle = { 'CommonUtils' => 'CommonUtils/Resources/*.*' }
end