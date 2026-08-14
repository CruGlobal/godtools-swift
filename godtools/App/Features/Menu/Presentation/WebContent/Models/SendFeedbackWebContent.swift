//
//  SendFeedbackWebContent.swift
//  godtools
//
//  Created by Rachael Skeath on 4/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct SendFeedbackWebContent: WebContentType {
    
    let appLanguage: AppLanguageDomainModel
    let navTitleLocalizedKey: String = LocalizableStringKeys.menuSendFeedback.key
    let url: URL? = URL(string: "https://godtoolsapp.com/send-feedback/")
    let analyticsScreenName: String = "Send Feedback"
    let analyticsSiteSection: String = "menu"
    let localizationServices: LocalizationServicesInterface
    
    private(set) var navTitle: String = ""
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServicesInterface) async {
        
        self.appLanguage = appLanguage
        self.localizationServices = localizationServices
        
        self.navTitle = await getLocalizedNavTitle()
    }
}
