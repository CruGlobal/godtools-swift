//
//  GodToolsAnaltyics.swift
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import AdobeMobileSDK

struct AdobeAnalyticsConstants {
    struct Keys {
        static let appName = "cru.appname"
        static let loggedInStatus = "cru.loggedinstatus"
        static let marketingCloudID = "cru.mcid"
        static let screenName = "cru.screenname"
        static let previousScreenName = "cru.previousscreenname"
    }
    
    struct Values {
        static let godTools = "GodTools"
        static let notLoggedIn = "not logged in"
    }
}
class GodToolsAnaltyics {
    let tracker = GAI.sharedInstance().tracker(withTrackingId: Config().googleAnalyticsApiKey)
    
    // Testing 2FA
    
    var previousScreenName = ""
    var adobeAnalyticsBackgroundQueue = DispatchQueue(label: "org.cru.godtools.adobeAnalytics",
                                                      qos: .background)
    
    private static var sharedInstance: GodToolsAnaltyics?
    
    static func setup() {
        let trackingID = Config().googleAnalyticsApiKey
        
        guard let gai = GAI.sharedInstance() else {
            return
        }
        
        gai.tracker(withTrackingId: trackingID)
        
        sharedInstance = GodToolsAnaltyics()
        
        #if DEBUG
            gai.logger.logLevel = .verbose
            gai.dryRun = true
        #endif
    }
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordScreenView(notification:)),
                                               name: .screenViewNotification,
                                               object: nil)
        
        recordAdwordsConversion()
        
        adobeAnalyticsBackgroundQueue.async { [unowned self] () in
            self.configureAdobeAnalytics()
        }
    }
    
    private func recordAdwordsConversion() {
        let conversionId = Config().googleAdwordsConversionId
        let label = Config().googleAdwordsLabel
        
        ACTConversionReporter.report(withConversionID: conversionId, label: label, value: "1.00", isRepeatable: false)
    }
    
    private func configureAdobeAnalytics() {
        loadAdobeAnalyticsConfigurationFile()
        var properties: [String: String] = [:]
        properties[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        properties[AdobeAnalyticsConstants.Keys.loggedInStatus] = AdobeAnalyticsConstants.Values.notLoggedIn
        properties[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        
        ADBMobile.collectLifecycleData(withAdditionalData: properties)
    }
    
    private func loadAdobeAnalyticsConfigurationFile() {
        var fileName = "ADBMobileConfig"
        
        #if DEBUG
            fileName = "ADBMobileConfig_debug"
        #endif
        
        let filePath = Bundle.main.path(forResource: fileName, ofType: "json")
        ADBMobile.overrideConfigPath(filePath)
    }
    
    @objc private func recordScreenView(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let screenName = userInfo[GTConstants.kAnalyticsScreenNameKey] as? String else {
            return
        }

        tracker?.set(kGAIScreenName, value: screenName)

        guard let screenViewInfo = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable : Any] else {
            return
        }
        
        tracker?.send(screenViewInfo)
        
        adobeAnalyticsBackgroundQueue.async { [unowned self] () in
            self.recordScreenViewInAdobe(screenName: screenName)
        }

    }
    
    private func recordScreenViewInAdobe(screenName: String) {
        var properties: [String: String] = [:]
        
        properties[AdobeAnalyticsConstants.Keys.screenName] = screenName
        properties[AdobeAnalyticsConstants.Keys.previousScreenName] = previousScreenName
        properties[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        properties[AdobeAnalyticsConstants.Keys.loggedInStatus] = AdobeAnalyticsConstants.Values.notLoggedIn
        properties[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        
        previousScreenName = screenName
        
        ADBMobile.trackState(screenName, data: properties)
    }
}
