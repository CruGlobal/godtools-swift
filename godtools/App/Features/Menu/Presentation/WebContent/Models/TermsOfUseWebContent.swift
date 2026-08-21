//
//  TermsOfUseWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TermsOfUseWebContent: WebContentType {
    
    let appLanguage: AppLanguageDomainModel
    let navTitleLocalizedKey: String = LocalizableStringKeys.termsOfUse.key
    let url: URL? = URL(string: "https://godtoolsapp.com/terms-of-use/")
    let analyticsScreenName: String = "Terms of Use"
    let analyticsSiteSection: String = "menu"
    let localizationServices: LocalizationServicesInterface
    
    private(set) var navTitle: String = ""
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServicesInterface) {
        
        self.appLanguage = appLanguage
        self.localizationServices = localizationServices
        
        self.navTitle = getLocalizedNavTitle()
    }
}
