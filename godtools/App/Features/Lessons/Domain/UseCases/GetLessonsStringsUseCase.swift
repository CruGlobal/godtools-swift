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

    func execute(translateInLanguage: AppLanguageDomainModel) async -> LessonsStringsDomainModel {

        let localeId: String = translateInLanguage
        
        let strings = LessonsStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsPageTitle.key),
            subtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsPageSubtitle.key),
            languageFilterTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsLanguageFilterTitle.key),
            personalizedToolToggleTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key),
            allLessonsToggleTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedToolToggleAllLessonsTitle.key),
            personalizedLessonExplanationTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedLessonFooterTitle.key),
            personalizedLessonExplanationSubtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedLessonFooterSubtitle.key),
            changeLocalizationSettingsAction: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key),
            viewAllLessonsAction: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsPersonalizationUnavailableViewAllLessons.key)
        )
        
        return strings
    }
}
