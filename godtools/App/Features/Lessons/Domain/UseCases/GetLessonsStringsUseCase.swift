//
//  GetLessonsStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLessonsStringsUseCase {

    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }

    func execute(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonsStringsDomainModel, Never> {

        let localeId: String = translateInLanguage
        
        let strings = LessonsStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsPageTitle.key),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsPageSubtitle.key),
            languageFilterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsLanguageFilterTitle.key),
            personalizedToolToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key),
            allLessonsToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedToolToggleAllLessonsTitle.key),
            personalizedLessonExplanationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedLessonFooterTitle.key),
            personalizedLessonExplanationSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedLessonFooterSubtitle.key),
            changeLocalizationSettingsAction: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key),
            viewAllLessonsAction: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsPersonalizationUnavailableViewAllLessons.key)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
