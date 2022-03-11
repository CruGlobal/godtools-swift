//
//  ContactUsWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ContactUsWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "http://www.godtoolsapp.com/#contact")
    let analyticsScreenName: String = "Contact Us"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "contact_us")
    }
}
