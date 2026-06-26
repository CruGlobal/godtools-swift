//
//  GetToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetToolsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> ToolsStringsDomainModel {
        
        let strings = ToolsStringsDomainModel(
            favoritingToolBannerMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolOfflineFavoriteMessage.key),
            toolSpotlightTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsSpotlightTitle.key),
            toolSpotlightSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsSpotlightSubtitle.key),
            filterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsFilterSectionTitle.key),
            personalizedToolToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key),
            allToolsToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolToggleAllToolsTitle.key),
            personalizedToolExplanationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolFooterTitle.key),
            personalizedToolExplanationSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolFooterSubtitle.key),
            changePersonalizedToolSettingsAction: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key),
            viewAllToolsAction: localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsPersonalizationUnavailableViewAllTools.key)
        )
        
        return strings
    }
}
