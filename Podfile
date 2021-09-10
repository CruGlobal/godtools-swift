
source 'https://cdn.cocoapods.org/'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!

# Specs finder:
# https://github.com/CocoaPods/Specs/find/master

target 'godtools' do
        
    pod 'AppsFlyerFramework', '~> 6.3.0'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'GoogleTagManager', '~> 7.2.0'
    pod 'FBSDKCoreKit', '~> 8.0.0'
    pod 'FirebaseCore', '7.11.0'
    pod 'FirebaseInAppMessaging', '7.11.0-beta'
    pod 'FirebaseAnalytics', '7.11.0'
    pod 'FirebaseCrashlytics', '7.11.0'
    pod 'Fuzi', '~> 3.1.1'
    pod 'lottie-ios', '~> 3.1.8'
    pod 'RealmSwift', '~> 10.7.4'
    pod 'SnowplowTracker', '~> 1.3'
    pod 'SSZipArchive', '~> 2.2.2'
    pod 'Starscream', '~> 4.0.0'
    pod 'SWXMLHash', '~> 5.0.1'
    pod 'TTTAttributedLabel', '~> 2.0.0'
    pod 'youtube-ios-player-helper', '~> 1.0.3'
    
    # CruGlobal pods
    # pod 'GodtoolsToolParser', '0.2.0'
    # pod 'GodtoolsToolParser', :git => 'https://github.com/CruGlobal/kotlin-mpp-godtools-tool-parser.git', :branch => 'iosFlows'
    pod 'GodtoolsToolParser', :path => '../GodToolsParser-KotlinMpp/'
    
    # TheKeyOAuthSwift requires dependency GTMAppAuth and pulls the latest version of GTMAppAuth.  Must force GTMAppAuth to version 0.7.0 because the latest version of GTMAppAuth pulls a version of AppAuth that is deprececated in TheKeyOAuthSwift causing errors in TheKeyOAuthSwift.
    pod 'TheKeyOAuthSwift'
    pod 'GTMAppAuth', '0.7.0'
    
    target 'godtoolsTests' do
        inherit! :search_paths
        # Pods for testing
    end
end

