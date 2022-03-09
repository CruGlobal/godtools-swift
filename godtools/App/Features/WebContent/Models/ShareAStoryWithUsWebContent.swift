//
//  ShareAStoryWithUsWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ShareAStoryWithUsWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "http://www.godtoolsapp.com/#contact")
    let analyticsScreenName: String = "Share Story"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "share_a_story_with_us")
    }
}
