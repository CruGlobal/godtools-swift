//
//  BaseAnalyticsAttributesModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct BaseAnalyticsAttributesModel {
    
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String
    let secondaryContentLanguage: String?
    let data: [String: Any]?
    
    init(screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String, secondaryContentLanguage: String?, data: [String: Any]?) {
        
        self.screenName = screenName
        self.siteSection = siteSection
        self.siteSubSection = siteSubSection
        self.contentLanguage = contentLanguage
        self.secondaryContentLanguage = secondaryContentLanguage
        self.data = data
    }
    
    init(screenName: String, siteSection: String, siteSubSection: String, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, data: [String: Any]?) {
        
        self.screenName = screenName
        self.siteSection = siteSection
        self.siteSubSection = siteSubSection
        self.contentLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage ?? ""
        self.secondaryContentLanguage = getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        self.data = data
    }
}
