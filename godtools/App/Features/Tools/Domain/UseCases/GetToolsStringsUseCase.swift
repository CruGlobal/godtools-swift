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
    
    func execute(translateInLanguage: AppLanguageDomainModel) async -> ToolsStringsDomainModel {
        
        let strings = ToolsStringsDomainModel(
            favoritingToolBannerMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolOfflineFavoriteMessage.key),
            toolSpotlightTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsSpotlightTitle.key),
            toolSpotlightSubtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsSpotlightSubtitle.key),
            filterTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsFilterSectionTitle.key),
            personalizedToolToggleTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key),
            allToolsToggleTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolToggleAllToolsTitle.key),
            personalizedToolExplanationTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolFooterTitle.key),
            personalizedToolExplanationSubtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolFooterSubtitle.key),
            changePersonalizedToolSettingsAction: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key),
            viewAllToolsAction: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: LocalizableStringKeys.toolsPersonalizationUnavailableViewAllTools.key)
        )
        
        return strings
    }
}
