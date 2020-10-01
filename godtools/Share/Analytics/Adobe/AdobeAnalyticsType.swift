//
//  AdobeAnalyticsType.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol AdobeAnalyticsType {
    
    var visitorMarketingCloudID: String { get }
    
    func configure()
    func collectLifecycleData()
    func trackScreenView(screenName: String, siteSection: String, siteSubSection: String)
    func trackAction(screenName: String?, actionName: String, data: [AnyHashable: Any])
    func trackExitLink(screenName: String, siteSection: String, siteSubSection: String, url: URL)
    func fetchAttributesThenSyncIds()
}
