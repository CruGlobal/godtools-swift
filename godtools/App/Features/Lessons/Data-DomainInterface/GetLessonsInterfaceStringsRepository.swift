//
//  GetLessonsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsInterfaceStringsRepository: GetLessonsInterfaceStringsRepositoryInterface {
 
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonsInterfaceStringsDomainModel, Never> {
     
        let localeId: String = translateInLanguage
        
        let interfaceStrings = LessonsInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.pageTitle"),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.pageSubtitle"),
            languageFilterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.languageFilter.title"),
            personalizedToolToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedToolToggle.personalizedTitle"),
            allLessonsToggleTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedToolToggle.allLessonsTitle"),
            personalizedLessonExplanationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedLessonFooter.title"),
            personalizedLessonExplanationSubtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedLessonFooter.subtitle"),
            changePersonalizedLessonSettingsActionLabel: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "dashboard.personalizedToolFooter.buttonTitle")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
