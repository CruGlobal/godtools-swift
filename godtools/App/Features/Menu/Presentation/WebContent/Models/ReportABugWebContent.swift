//
//  ReportABugWebContent.swift
//  godtools
//
//  Created by Rachael Skeath on 4/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ReportABugWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://form.asana.com/?k=2XgC7iGos5JKqEsgyr_WWA&d=657768513276")
    let analyticsScreenName: String = "Report A Bug"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "menu.reportABug")
    }
}
