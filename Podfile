
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
    
    pod 'Firebase', '6.32.0'
    pod 'Firebase/InAppMessaging', '6.32.0'
    pod 'Firebase/Analytics', '6.32.0'
    
    pod 'AdobeMobileSDK', '~> 4.19'
    pod 'AppsFlyerFramework', '~> 6.0.0'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'GoogleTagManager'
    pod 'Crashlytics'
    pod 'Fabric'
    pod 'FacebookCore'
    pod 'Fuzi'
    pod 'lottie-ios'
    pod 'RealmSwift'
    pod 'SnowplowTracker', '~> 1.3'
    pod 'SSZipArchive'
    pod 'Starscream', '~> 4.0.0'
    pod 'SWXMLHash'
    pod 'SwiftyJSON'
    pod 'TTTAttributedLabel'
    pod 'YoutubePlayer-in-WKWebView', '~> 0.3.0'
    
    # TheKeyOAuthSwift requires dependency GTMAppAuth and pulls the latest version of GTMAppAuth.  Must force GTMAppAuth to version 0.7.0 because the latest version of GTMAppAuth pulls a version of AppAuth that is deprececated in TheKeyOAuthSwift causing errors in TheKeyOAuthSwift.
    pod 'TheKeyOAuthSwift'
    pod 'GTMAppAuth', '0.7.0'
    
    target 'godtoolsTests' do
        inherit! :search_paths
        # Pods for testing
    end
end

