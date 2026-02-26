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
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.pageTitle"),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.pageSubtitle"),
            languageFilterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.languageFilter.title"),
            personalizedToolToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedToolToggle.personalizedTitle"),
            allLessonsToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedToolToggle.allLessonsTitle"),
            personalizedLessonExplanationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedLessonFooter.title"),
            personalizedLessonExplanationSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedLessonFooter.subtitle"),
            changePersonalizedLessonSettingsActionLabel: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedToolFooter.buttonTitle")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
