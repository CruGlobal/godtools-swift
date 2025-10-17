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
    let url: URL? = URL(string: "https://godtoolsapp.com/share-story/")
    let analyticsScreenName: String = "Share Story"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServicesInterface) {
        
        navTitle = localizationServices.stringForSystemElseEnglish(key: "share_a_story_with_us")
    }
}
