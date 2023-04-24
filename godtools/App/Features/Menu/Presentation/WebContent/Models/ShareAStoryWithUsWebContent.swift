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
    let url: URL? = URL(string: "https://form.asana.com/?k=L7M3jdnAh7S414z8fN_YsQ&d=657768513276")
    let analyticsScreenName: String = "Share Story"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "share_a_story_with_us")
    }
}
