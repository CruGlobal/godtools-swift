//
//  HelpWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct HelpWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "http://www.godtoolsapp.com/faq")
    let analyticsScreenName: String = "Help"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "help")
    }
}
