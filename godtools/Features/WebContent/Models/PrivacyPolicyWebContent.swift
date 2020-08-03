//
//  PrivacyPolicyWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct PrivacyPolicyWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://www.cru.org/about/privacy.html")
    let analyticsScreenName: String = "Privacy Policy"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "privacy_policy")
    }
}
