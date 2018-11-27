source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

target 'godtools' do

  pod 'Alamofire', '~> 4'
  pod 'PromiseKit', '~> 4'
  pod 'PromiseKit/Alamofire', '~> 4'
  pod 'RealmSwift', '~> 2.10'
  pod 'SSZipArchive'
  pod 'SWXMLHash', '~> 4.1'
  pod 'Fuzi'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'CRUConfig', '~> 1.2'
  pod 'GoogleAnalytics'
  pod 'GoogleConversionTracking'
  pod 'AdobeMobileSDK', '~> 4.15'
  pod 'TheKeyOAuthSwift', '~> 0.5.5'
  pod 'SwiftyJSON', '~> 4.1.0'
end

post_install do |installer|
    
#    print "Setting the default SWIFT_VERSION to 4.2 fro every pod\n"
#    installer.pods_project.build_configurations.each do |config|
#       config.build_settings['SWIFT_VERSION'] = '4.2'
#    end

    installer.pods_project.targets.each do |target|
        # pods that require new swift
        if ['Fuzi'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end
    end
end
