
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
    
    pod 'AdobeMobileSDK', '~> 4.19'
    pod 'AppsFlyerFramework', '~> 6.0.0'
    pod 'Crashlytics', '~> 3.14.0'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'GoogleTagManager', '~> 7.1.4'
    pod 'Fabric', '~> 1.10.2'
    pod 'FacebookCore', '~> 0.9.0'
    pod 'Firebase', '6.32.0'
    pod 'Firebase/InAppMessaging', '6.32.0'
    pod 'Firebase/Analytics', '6.32.0'
    pod 'Fuzi', '~> 3.1.1'
    pod 'lottie-ios', '~> 3.1.8'
    pod 'RealmSwift', '~> 4.3.0'
    pod 'SnowplowTracker', '~> 1.3'
    pod 'SSZipArchive', '~> 2.2.2'
    pod 'Starscream', '~> 4.0.0'
    pod 'SWXMLHash', '~> 5.0.1'
    pod 'TTTAttributedLabel', '~> 2.0.0'
    pod 'YoutubePlayer-in-WKWebView', '~> 0.3.0'
    
    # TheKeyOAuthSwift requires dependency GTMAppAuth and pulls the latest version of GTMAppAuth.  Must force GTMAppAuth to version 0.7.0 because the latest version of GTMAppAuth pulls a version of AppAuth that is deprececated in TheKeyOAuthSwift causing errors in TheKeyOAuthSwift.
    pod 'TheKeyOAuthSwift'
    pod 'GTMAppAuth', '0.7.0'
    
    target 'godtoolsTests' do
        inherit! :search_paths
        # Pods for testing
    end
end

