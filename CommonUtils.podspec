Pod::Spec.new do |s|
  s.name         = 'CommonUtils'
  s.version      = '1.4.73'
  s.summary      = 'Common Utilities.'
  s.homepage     = 'https://bitbucket.org/mrklteam/commonutils'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Karen Lusinyan' => 'karen.lusinyan.developerios@gmail.com' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://mrcararia@bitbucket.org/mrklteam/commonutils.git', :tag => s.version.to_s }

  s.prefix_header_file = 'CommonUtils/Classes/Lib-Prefix.pch'

  non_arc_files  = 'CommonUtils/Classes/Categories/NSString/GTMNSString+HTML.{h,m}',
                   'CommonUtils/Classes/Categories/NSString/NSString+HTML.{h,m}',
                   'CommonUtils/Classes/Network/CUReachability.{h,m}'

  s.requires_arc = true
  s.source_files = 'CommonUtils/Classes/**/*.{h,m}'
  s.exclude_files = non_arc_files
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  s.dependency 'AFNetworking'
  s.dependency 'Canvas'

  #s.resource_bundles = {
  #  'Nibs'   => ['CommonUtils/Resources/Images/**/*.*'],
  #  'Images' => ['CommonUtils/Resources/Images/**/*.*'],
  #  'Sounds' => ['CommonUtils/Resources/Sounds/**/*.*'],
  #  'CommonProgress' => ['CommonUtils/Resources/CommonProgress.bundle']
  #}

  s.resource_bundles = { 'CommonUtils' => ['CommonUtils/Resources/Nibs/**/*.*', 'CommonUtils/Resources/Images/**/*.*', 'CommonUtils/Resources/Sounds/**/*.*', 'CommonUtils/Classes/Controllers/Progress/CommonProgress.bundle', 'CommonUtils/Classes/Controllers/BarcodeReader/CommonBarcode.bundle', 'CommonUtils/Classes/SplitViewController/Split.bundle'] }

  #-------- Frameworks --------
  s.frameworks = 'SystemConfiguration','MobileCoreServices'
  #---------------------------

end