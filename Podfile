
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
    
    pod 'CRUConfig', '~> 1.2'
    pod 'RealmSwift', '4.3.0'
    pod 'SSZipArchive'
    pod 'SWXMLHash'
    pod 'Fuzi'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'GoogleAnalytics', '~> 3.17.0'
    pod 'GoogleConversionTracking', '~> 3.4.0'
    pod 'AdobeMobileSDK', '~> 4.17.1'
    pod 'SwiftyJSON'
    pod 'TTTAttributedLabel'
    pod 'Firebase/Analytics'
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

