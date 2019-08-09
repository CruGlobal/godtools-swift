source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

target 'godtools' do
    
    pod 'Alamofire', '~> 4.8'
    pod 'PromiseKit', '~> 6.8'
    pod 'PromiseKit/Alamofire', '~> 6.8'
    
    pod 'CRUConfig', '~> 1.2'
    pod 'RealmSwift', '~> 3.16'
    pod 'SSZipArchive'
    pod 'SWXMLHash'
    pod 'Fuzi'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'GoogleAnalytics', '~> 3.17.0'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'AdobeMobileSDK', '~> 4.17.1'
    pod 'TheKeyOAuthSwift'
    pod 'SwiftyJSON'
    pod 'TTTAttributedLabel'
    pod 'Firebase/Analytics'
end

post_install do |installer|
    print "Setting the default SWIFT_VERSION to 5.0 for every pod\n"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5'
    end
    
    #     installer.pods_project.targets.each do |target|
    #         # pods that require old swift
    #         if ['Alamofire','PromiseKit', 'PromiseKit/Alamofire'].include? target.name
    #             print "#{target}'s SWIFT_VERSION = 3\n"
    #             target.build_configurations.each do |config|
    #                 config.build_settings['SWIFT_VERSION'] = '3.0'
    #             end
    #             else
    #             print "#{target}'s SWIFT_VERSION = Undefined (Xcode will automatically resolve to 4.2)\n"
    #             target.build_configurations.each do |config|
    #                 config.build_settings.delete('SWIFT_VERSION')
    #             end
    #         end
    
    #     end
end

