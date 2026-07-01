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
    let url: URL? = URL(string: "https://godtoolsapp.com/report-bug/")
    let analyticsScreenName: String = "Report A Bug"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServicesInterface) {
        
        navTitle = localizationServices.stringForSystemElseEnglish(key: LocalizableStringKeys.menuReportABug.key)
    }
}
