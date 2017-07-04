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
    }
}
