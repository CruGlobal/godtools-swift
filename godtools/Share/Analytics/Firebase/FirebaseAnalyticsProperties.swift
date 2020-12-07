//
//  FirebaseAnalyticsProperties.swift
//  godtools
//
//  Created by Robert Eldredge on 12/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FirebaseAnalyticsProperties: Encodable {
    
    var appName: String?
    var contentLanguage: String?
    var contentLanguageSecondary: String?
    var exitLink: String?
    var grMasterPersonID: String?
    var loggedInStatus: String?
    //var marketingCloudID: String?
    var previousScreenName: String?
    var screenName: String?
    var siteSection: String?
    var siteSubSection: String?
    var ssoguid: String?
    
    enum CodingKeys: String, CodingKey {
        
        case appName = "cru_appname"
        case contentLanguage = "cru_contentlanguage"
        case contentLanguageSecondary = "cru_contentlanguagesecondary"
        case exitLink = "cru_mobileexitlink"
        case grMasterPersonID = "cru_grmpid"
        case loggedInStatus = "cru_loggedinstatus"
        //case marketingCloudID = "cru_mcid"
        case previousScreenName = "cru_previousscreenname"
        case screenName = "cru_screenname"
        case siteSection = "cru_siteSection"
        case siteSubSection = "cru_siteSubSection"
        case ssoguid = "cru_ssoguid"
    }
}
