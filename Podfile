source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

target 'godtools' do

  pod 'Alamofire', '~> 4.4'
  pod 'PromiseKit', '~> 4.1'
  pod 'PromiseKit/Alamofire', '~> 4.1'
  pod 'MagicalRecord', '~> 2.3'
  pod 'SSZipArchive'
  pod 'SWXMLHash', '~> 3.0.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Spine', :git => 'https://github.com/CruGlobal/Spine.git', :tag => '0.3.1'

  target 'godtoolsTests' do
    inherit! :search_paths
    pod 'Quick', '1.1'
    pod 'Nimble', '~> 6.1'
  end

end
