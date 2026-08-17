//
//  GetLessonsStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetLessonsStringsUseCase: Sendable {

    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }

    func execute(translateInLanguage: AppLanguageDomainModel) -> LessonsStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.lessonsPageTitle.key
        let subtitleKey: String = LocalizableStringKeys.lessonsPageSubtitle.key
        let languageFilterTitleKey: String = LocalizableStringKeys.lessonsLanguageFilterTitle.key
        let personalizedToolToggleTitleKey: String = LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key
        let allLessonsToggleTitleKey: String = LocalizableStringKeys.dashboardPersonalizedToolToggleAllLessonsTitle.key
        let personalizedLessonExplanationTitleKey: String = LocalizableStringKeys.dashboardPersonalizedLessonFooterTitle.key
        let personalizedLessonExplanationSubtitleKey: String = LocalizableStringKeys.dashboardPersonalizedLessonFooterSubtitle.key
        let changeLocalizationSettingsActionKey: String = LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key
        let viewAllLessonsActionKey: String = LocalizableStringKeys.lessonsPersonalizationUnavailableViewAllLessons.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                subtitleKey,
                languageFilterTitleKey,
                personalizedToolToggleTitleKey,
                allLessonsToggleTitleKey,
                personalizedLessonExplanationTitleKey,
                personalizedLessonExplanationSubtitleKey,
                changeLocalizationSettingsActionKey,
                viewAllLessonsActionKey
            ],
            fetchOrder: [
                .locale(identifier: translateInLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return LessonsStringsDomainModel(
            title: strings[titleKey] ?? "",
            subtitle: strings[subtitleKey] ?? "",
            languageFilterTitle: strings[languageFilterTitleKey] ?? "",
            personalizedToolToggleTitle: strings[personalizedToolToggleTitleKey] ?? "",
            allLessonsToggleTitle: strings[allLessonsToggleTitleKey] ?? "",
            personalizedLessonExplanationTitle: strings[personalizedLessonExplanationTitleKey] ?? "",
            personalizedLessonExplanationSubtitle: strings[personalizedLessonExplanationSubtitleKey] ?? "",
            changeLocalizationSettingsAction: strings[changeLocalizationSettingsActionKey] ?? "",
            viewAllLessonsAction: strings[viewAllLessonsActionKey] ?? ""
        )
    }
}
