//
//  GodToolsAnaltyics.swift
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import AdobeMobileSDK
import TheKeyOAuthSwift

struct AdobeAnalyticsConstants {
    struct Keys {
        static let appName = "cru.appname"
        static let loggedInStatus = "cru.loggedinstatus"
        static let marketingCloudID = "cru.mcid"
        static let screenName = "cru.screenname"
        static let siteSection = "cru.siteSection"
        static let siteSubSection = "cru.siteSubSection"
        static let previousScreenName = "cru.previousscreenname"
        static let contentLanguage = "cru.contentlanguage"
        static let contentLanguageSecondary = "cru.contentlanguagesecondary"
        static let shareAction = "cru.shareiconengaged"
        static let exitAction = "cru.mobileexitlink"
        static let toggleAction = "cru.toggleswitch"
        static let gospelPresentedTimedAction = "cru.presentingthegospel"
        static let presentingHolySpiritTimedAction = "cru.presentingtheholyspirit"
        static let newProfessingBelieverAction = "cru.newprofessingbelievers"
        static let emailSignUpAction = "cru.emailsignup"
    }
    
    struct Values {
        static let godTools = "GodTools"
        static let isLoggedIn = "is logged in"
        static let notLoggedIn = "not logged in"
        static let share = "Share Icon Engaged"
        static let exitLink = "Exit Link Engaged"
        static let kgpUSCircleToggled = "KGP-US Circle Toggled"
        static let kgpCircleToggled = "KGP Circle Toggled"
        static let kgpGospelPresented = "KGP Gospel Presented"
        static let kgpUSGospelPresented = "KGP-US Gospel Presented"
        static let fourLawsGospelPresented = "FourLaws Gospel Presented"
        static let theFourGospelPresented = "TheFour Gospel Presented"
        static let satisfiedHolySpiritPresented = "Satisfied Holy Spirit Presented"
        static let honorRestoredPresented = "HonorRestored Gospel Presented"
        static let kgpNewProfessingBeliever = "KGP New Professing Believer"
        static let kgpUSNewProfessingBeliever = "KGP-US New Professing Believer"
        static let fourLawsNewProfessingBeliever = "FourLaws New Professing Believer"
        static let theFourNewProfessingBeliever = "TheFour New Professing Believer"
        static let kgpEmailSignUp = "KGP Email Sign Up"
        static let fourLawsEmailSignUp = "FourLaws Email Sign Up"
    }
}
class GodToolsAnaltyics {
    let tracker = GAI.sharedInstance().tracker(withTrackingId: Config().googleAnalyticsApiKey)
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordActionForADBMobile(notification:)),
                                               name: .actionTrackNotification,
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
        properties[AdobeAnalyticsConstants.Keys.loggedInStatus] = isUserLoggedIn()
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
        let siteSection = userInfo[AdobeAnalyticsConstants.Keys.siteSection] as? String ?? ""
        let siteSubSection = userInfo[AdobeAnalyticsConstants.Keys.siteSubSection] as? String ?? ""

        tracker?.set(kGAIScreenName, value: screenName)

        guard let screenViewInfo = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable : Any] else {
            return
        }
        
        tracker?.send(screenViewInfo)
        
        adobeAnalyticsBackgroundQueue.async { [unowned self] () in
            self.recordScreenViewInAdobe(screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection)
        }

    }
    
    @objc private func recordActionForADBMobile(notification: Notification) {
        var contextData: [String: Any] = [:]
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let action = userInfo["action"] as? String else { return }

        contextData = userInfo
        contextData[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        contextData[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        contextData.removeValue(forKey: "action")
        
        adobeAnalyticsBackgroundQueue.async { [unowned self] () in
            self.trackActionInAdobe(actionName: action, data: contextData)
            debugPrint("\(contextData.debugDescription)")
        }
    }

    
    private func trackActionInAdobe(actionName: String, data: [String: Any]) {
        ADBMobile.trackAction(actionName, data: data)
    }
    
    private func recordScreenViewInAdobe(screenName: String, siteSection: String, siteSubSection: String) {
        var properties: [String: String] = [:]
        let primaryLanguageCode = UserDefaults.standard.string(forKey: "kPrimaryLanguageCode") ?? ""
        let parallelLanguageCode = UserDefaults.standard.string(forKey: "kParallelLanguageCode") ?? ""
        
        properties[AdobeAnalyticsConstants.Keys.screenName] = screenName
        properties[AdobeAnalyticsConstants.Keys.previousScreenName] = previousScreenName
        properties[AdobeAnalyticsConstants.Keys.siteSection] = siteSection
        properties[AdobeAnalyticsConstants.Keys.siteSubSection] = siteSubSection
        properties[AdobeAnalyticsConstants.Keys.contentLanguage] = primaryLanguageCode
        properties[AdobeAnalyticsConstants.Keys.contentLanguageSecondary] = parallelLanguageCode
        properties[AdobeAnalyticsConstants.Keys.appName] = AdobeAnalyticsConstants.Values.godTools
        properties[AdobeAnalyticsConstants.Keys.loggedInStatus] = isUserLoggedIn()
        properties[AdobeAnalyticsConstants.Keys.marketingCloudID] = ADBMobile.visitorMarketingCloudID()
        
        previousScreenName = screenName
        
        ADBMobile.trackState(screenName, data: properties)
        debugPrint("\(properties.debugDescription)")
    }
    
    private func isUserLoggedIn() -> String {
        let client = TheKeyOAuthClient.shared
        if client.isAuthenticated() {
            return AdobeAnalyticsConstants.Values.isLoggedIn
        } else {
            return AdobeAnalyticsConstants.Values.notLoggedIn
        }
    }
    
}
