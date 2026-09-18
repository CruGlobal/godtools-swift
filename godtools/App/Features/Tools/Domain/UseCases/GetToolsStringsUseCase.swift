//
//  GetToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetToolsStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> ToolsStringsDomainModel {

        let favoritingToolBannerMessageKey: String = LocalizableStringKeys.toolOfflineFavoriteMessage.key
        let featuredToolsTitleKey: String = LocalizableStringKeys.toolsFeaturedTitle.key
        let featuredToolsSubtitleKey: String = LocalizableStringKeys.toolsFeaturedSubtitle.key
        let filterTitleKey: String = LocalizableStringKeys.toolsFilterSectionTitle.key
        let personalizedToolToggleTitleKey: String = LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key
        let allToolsToggleTitleKey: String = LocalizableStringKeys.dashboardPersonalizedToolToggleAllToolsTitle.key
        let personalizedToolExplanationTitleKey: String = LocalizableStringKeys.dashboardPersonalizedToolFooterTitle.key
        let personalizedToolExplanationSubtitleKey: String = LocalizableStringKeys.dashboardPersonalizedToolFooterSubtitle.key
        let changePersonalizedToolSettingsActionKey: String = LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key
        let viewAllToolsActionKey: String = LocalizableStringKeys.toolsPersonalizationUnavailableViewAllTools.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                favoritingToolBannerMessageKey,
                featuredToolsTitleKey,
                featuredToolsSubtitleKey,
                filterTitleKey,
                personalizedToolToggleTitleKey,
                allToolsToggleTitleKey,
                personalizedToolExplanationTitleKey,
                personalizedToolExplanationSubtitleKey,
                changePersonalizedToolSettingsActionKey,
                viewAllToolsActionKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: translateInLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ToolsStringsDomainModel(
            favoritingToolBannerMessage: strings[favoritingToolBannerMessageKey] ?? "",
            toolSpotlightTitle: strings[featuredToolsTitleKey] ?? "",
            toolSpotlightSubtitle: strings[featuredToolsSubtitleKey] ?? "",
            filterTitle: strings[filterTitleKey] ?? "",
            personalizedToolToggleTitle: strings[personalizedToolToggleTitleKey] ?? "",
            allToolsToggleTitle: strings[allToolsToggleTitleKey] ?? "",
            personalizedToolExplanationTitle: strings[personalizedToolExplanationTitleKey] ?? "",
            personalizedToolExplanationSubtitle: strings[personalizedToolExplanationSubtitleKey] ?? "",
            changePersonalizedToolSettingsAction: strings[changePersonalizedToolSettingsActionKey] ?? "",
            viewAllToolsAction: strings[viewAllToolsActionKey] ?? ""
        )
    }
}
