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
    
    let appName: String?
    let contentLanguage: String?
    let contentLanguageSecondary: String?
    var exitLink: String?
    let grMasterPersonID: String?
    let loggedInStatus: String?
    let marketingCloudID: String?
    let previousScreenName: String?
    let screenName: String?
    let siteSection: String?
    let siteSubSection: String?
    let ssoguid: String?
    
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
