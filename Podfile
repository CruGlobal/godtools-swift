source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

target 'godtools' do
    
    pod 'Alamofire', '~> 4'
    #pod 'PromiseKit', '~> 4'
    pod 'PromiseKit/CorePromise', '~> 4'
    pod 'PromiseKit/Foundation', '~> 4'
    pod 'PromiseKit/Alamofire', '~> 4'
    
    pod 'CRUConfig', '~> 1.2'
    pod 'RealmSwift', '~> 3.12'
    pod 'SSZipArchive'
    pod 'SWXMLHash', '~> 4.8.0'
    pod 'Fuzi', '~> 2.1'
    pod 'Fabric', '~> 1.9'
    pod 'Crashlytics', '~> 3.12.0'
    pod 'GoogleAnalytics', '~> 3.17.0'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'AdobeMobileSDK', '~> 4.17.1'
    pod 'TheKeyOAuthSwift'
    pod 'SwiftyJSON', '~> 4.1.0'
    pod 'TTTAttributedLabel'
    
end

post_install do |installer|
    
    print "Setting the default SWIFT_VERSION to 4.2 for every pod\n"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
    end
    
    # installer.pods_project.targets.each do |target|
    #     # pods that require old swift
    #     if ['Alamofire','PromiseKit', 'PromiseKit/Alamofire'].include? target.name
    #         print "#{target}'s SWIFT_VERSION = 3\n"
    #         target.build_configurations.each do |config|
    #             config.build_settings['SWIFT_VERSION'] = '3.0'
    #         end
    #         else
    #         print "#{target}'s SWIFT_VERSION = Undefined (Xcode will automatically resolve to 4.2)\n"
    #         target.build_configurations.each do |config|
    #             config.build_settings.delete('SWIFT_VERSION')
    #         end
    #     end
        
    # end
end

#  target 'godtools' do
#
#     pod 'Alamofire', '~> 4'
#     pod 'PromiseKit', '~> 4'
#     pod 'PromiseKit/Alamofire', '~> 4'
#     pod 'RealmSwift'
#
#     pod 'SSZipArchive'
#     pod 'SWXMLHash', '~> 4.1'
#     pod 'Fuzi'
#     pod 'Fabric'
#
#     pod 'Crashlytics'
#     pod 'CRUConfig', '~> 1.2'
#     pod 'GoogleAnalytics'
#     pod 'GoogleConversionTracking'
#
#     pod 'AdobeMobileSDK', '~> 4'
#     pod 'TheKeyOAuthSwift', '~> 0.5.5'
#     pod 'SwiftyJSON', '~> 4.1.0'
#     pod 'TTTAttributedLabel'
#
#  end
#
#  post_install do |installer|
#
#      print "Setting the default SWIFT_VERSION to 3.0 for every pod\n"
#      installer.pods_project.build_configurations.each do |config|
#          config.build_settings['SWIFT_VERSION'] = '3.0'
#      end
#
#      installer.pods_project.targets.each do |target|
#          # pods that require new swift
#          if ['Fuzi','TTTAttributedLabel'].include? target.name
#              target.build_configurations.each do |config|
#                  config.build_settings['SWIFT_VERSION'] = '4.2'
#              end
#          else
#              target.build_configurations.each do |config|
#                  config.build_settings.delete('SWIFT_VERSION')
#              end
#          end
#      end
#  end


