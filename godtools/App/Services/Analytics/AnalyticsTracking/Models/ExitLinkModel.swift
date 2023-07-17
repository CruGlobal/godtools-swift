//
//  ExitLinkModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/18/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ExitLinkModel {
    
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String
    let secondaryContentLanguage: String?
    let url: URL
    
    init(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String, secondaryContentLanguage: String?, url: URL) {
        
        self.screenName = screenName
        self.siteSection = siteSection
        self.siteSubSection = siteSubSection
        self.contentLanguage = contentLanguage
        self.secondaryContentLanguage = secondaryContentLanguage
        self.url = url
    }
    
    init(baseAnalyticsAttributes: BaseAnalyticsAttributesModel, url: URL) {
        
        self.screenName = baseAnalyticsAttributes.screenName
        self.siteSection = baseAnalyticsAttributes.siteSection
        self.siteSubSection = baseAnalyticsAttributes.siteSubSection
        self.contentLanguage = baseAnalyticsAttributes.contentLanguage
        self.secondaryContentLanguage = baseAnalyticsAttributes.secondaryContentLanguage
        self.url = url
    }
}
