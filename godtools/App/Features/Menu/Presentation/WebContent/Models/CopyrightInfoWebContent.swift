//
//  CopyrightInfoWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

struct CopyrightInfoWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://godtoolsapp.com/copyright")
    let analyticsScreenName: String = "Copyright Info"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServicesInterface) {
        
        navTitle = localizationServices.stringForSystemElseEnglish(key: "copyright_info")
    }
}
