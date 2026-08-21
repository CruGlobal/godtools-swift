//
//  ShareAStoryWithUsWebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ShareAStoryWithUsWebContent: WebContentType {
    
    let appLanguage: AppLanguageDomainModel
    let navTitleLocalizedKey: String = LocalizableStringKeys.shareAStoryWithUs.key
    let url: URL? = URL(string: "https://godtoolsapp.com/share-story/")
    let analyticsScreenName: String = "Share Story"
    let analyticsSiteSection: String = "menu"
    let localizationServices: LocalizationServicesInterface
    
    private(set) var navTitle: String = ""
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServicesInterface) {
        
        self.appLanguage = appLanguage
        self.localizationServices = localizationServices
        
        self.navTitle = getLocalizedNavTitle()
    }
}
