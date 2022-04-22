
source 'https://cdn.cocoapods.org/'
source 'https://github.com/CruGlobal/cocoapods-specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!

# Specs finder:
# https://github.com/CocoaPods/Specs/find/master

def shared_pods
  
  # CruGlobal pods
  pod 'GodtoolsToolParser', '0.6.0-SNAPSHOT'
end

target 'godtools' do
        
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'GoogleTagManager', '~> 7.2.0'
    pod 'FBSDKCoreKit', '~> 8.2.0'
    pod 'FirebaseCore', '7.11.0'
    pod 'FirebaseInAppMessaging', '7.11.0-beta'
    pod 'FirebaseAnalytics', '7.11.0'
    pod 'FirebaseCrashlytics', '7.11.0'
    pod 'Fuzi', '~> 3.1.1'
    pod 'SnowplowTracker', '~> 1.3'
    pod 'SSZipArchive', '~> 2.4.0'
    pod 'Starscream', '~> 4.0.0'
    pod 'SWXMLHash', '~> 5.0.1'
    pod 'TTTAttributedLabel', '~> 2.0.0'
    pod 'youtube-ios-player-helper', '~> 1.0.3'
    
    shared_pods
end

target 'godtoolsTests' do
    
  shared_pods
end
