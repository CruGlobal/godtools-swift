//
//  AskAQuestionWebContent.swift
//  godtools
//
//  Created by Rachael Skeath on 4/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AskAQuestionWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://form.asana.com/?k=xwsmGveP8Os1JlqJ3Q4S_A&d=657768513276")
    let analyticsScreenName: String = "Ask A Question"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "menu.askAQuestion")
    }
}
