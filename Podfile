
source 'https://cdn.cocoapods.org/'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!

# Specs finder:
# https://github.com/CocoaPods/Specs/find/master

target 'godtools' do
    
    pod 'Alamofire', '~> 4.8'
    pod 'PromiseKit', '~> 6.8'
    pod 'PromiseKit/Alamofire', '~> 6.8'
    
    pod 'Firebase', '6.16.0'
    pod 'Firebase/InAppMessaging', '6.16.0'
    pod 'Firebase/Analytics', '6.16.0'
    
    pod 'AppsFlyerFramework', '5.1.0'
    pod 'SnowplowTracker', '~> 1.3'
    pod 'RealmSwift'
    pod 'SSZipArchive'
    pod 'SWXMLHash'
    pod 'Fuzi'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'AdobeMobileSDK', '~> 4.19'
    pod 'SwiftyJSON'
    pod 'TTTAttributedLabel'
    pod 'FacebookCore'
    pod "YoutubePlayer-in-WKWebView", "~> 0.3.0"
    
    # TheKeyOAuthSwift requires dependency GTMAppAuth and pulls the latest version of GTMAppAuth.  Must force GTMAppAuth to version 0.7.0 because the latest version of GTMAppAuth pulls a version of AppAuth that is deprececated in TheKeyOAuthSwift causing errors in TheKeyOAuthSwift.
    pod 'TheKeyOAuthSwift'
    pod 'GTMAppAuth', '0.7.0'
    
    target 'godtoolsTests' do
        inherit! :search_paths
        # Pods for testing
    end
end

