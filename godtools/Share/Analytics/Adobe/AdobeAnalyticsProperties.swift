//
//  AdobeAnalyticsProperties.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift

struct AdobeAnalyticsProperties: Encodable {
    
    var appName: String?
    var contentLanguage: String?
    var contentLanguageSecondary: String?
    var exitLink: String?
    var grMasterPersonID: String?
    var loggedInStatus: String?
    var marketingCloudID: String?
    var previousScreenName: String?
    var screenName: String?
    var siteSection: String?
    var siteSubSection: String?
    var ssoguid: String?
    
    enum CodingKeys: String, CodingKey {
        
        case appName = "cru.appname"
        case contentLanguage = "cru.contentlanguage"
        case contentLanguageSecondary = "cru.contentlanguagesecondary"
        case exitLink = "cru.mobileexitlink"
        case grMasterPersonID = "cru.grmpid"
        case loggedInStatus = "cru.loggedinstatus"
        case marketingCloudID = "cru.mcid"
        case previousScreenName = "cru.previousscreenname"
        case screenName = "cru.screenname"
        case siteSection = "cru.siteSection"
        case siteSubSection = "cru.siteSubSection"
        case ssoguid = "cru.ssoguid"
    }
}
