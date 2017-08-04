//
//  GodToolsAnaltyics.swift
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class GodToolsAnaltyics {
    let tracker = GAI.sharedInstance().tracker(withTrackingId: Config().googleAnalyticsApiKey)
    
    var previousScreenName = ""
    
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
        configureAdobeAnalytics()
    }
    
    private func recordAdwordsConversion() {
        let conversionId = Config().googleAdwordsConversionId
        let label = Config().googleAdwordsLabel
        
        ACTConversionReporter.report(withConversionID: conversionId, label: label, value: "1.00", isRepeatable: false)
    }
    
    private func configureAdobeAnalytics() {
        var properties: [String: String] = [:]
        properties["cru.appname"] = "GodTools"
        properties["cru.loggedinstatus"] = "not logged in"
        properties["cru.mcid"] = ADBMobile.visitorMarketingCloudID()
        
        ADBMobile.collectLifecycleData(withAdditionalData: properties)
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
        
        recordScreenViewInAdobe(screenName: screenName)
    }
    
    private func recordScreenViewInAdobe(screenName: String) {
        var properties: [String: String] = [:]
        
        properties["cru.screenname"] = "GodTools : \(screenName)"
        properties["cru.previousscreenname"] = "GodTools : \(previousScreenName)"
        properties["cru.appname"] = "GodTools"
        properties["cru.loggedinstatus"] = "not logged in"
        properties["cru.mcid"] = ADBMobile.visitorMarketingCloudID()
        
        previousScreenName = screenName
        
        ADBMobile.trackState(screenName, data: properties)
    }
}
