//
//  CopyrightInfoWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct CopyrightInfoWebContent: WebContentType {
    
    let appLanguage: AppLanguageDomainModel
    let navTitleLocalizedKey: String = LocalizableStringKeys.copyrightInfo.key
    let url: URL? = URL(string: "https://godtoolsapp.com/copyright")
    let analyticsScreenName: String = "Copyright Info"
    let analyticsSiteSection: String = "menu"
    let localizationServices: LocalizationServicesInterface
    
    private(set) var navTitle: String = ""
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServicesInterface) async {
        
        self.appLanguage = appLanguage
        self.localizationServices = localizationServices
        
        self.navTitle = getLocalizedNavTitle()
    }
}
