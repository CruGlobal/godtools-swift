//
//  TermsOfUseWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

struct TermsOfUseWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://godtoolsapp.com/terms-of-use/")
    let analyticsScreenName: String = "Terms of Use"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServicesInterface) {
        
        navTitle = localizationServices.stringForSystemElseEnglish(key: "terms_of_use")
    }
}
