//
//  PrivacyPolicyWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct PrivacyPolicyWebContent: WebContentType {
    
    let appLanguage: AppLanguageDomainModel
    let navTitleLocalizedKey: String = LocalizableStringKeys.privacyPolicy.key
    let url: URL? = URL(string: "https://www.cru.org/about/privacy.html")
    let analyticsScreenName: String = "Privacy Policy"
    let analyticsSiteSection: String = "menu"
    let localizationServices: LocalizationServicesInterface
    
    private(set) var navTitle: String = ""
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServicesInterface) {
        
        self.appLanguage = appLanguage
        self.localizationServices = localizationServices
        
        self.navTitle = getLocalizedNavTitle()
    }
}
