//
//  GetLessonSwipeTutorialInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetLessonSwipeTutorialInterfaceStringsRepository: GetLessonSwipeTutorialInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonSwipeTutorialInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage.localeId
        
        let interfaceStrings = LessonSwipeTutorialInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.swipeTutorial.title"),
            closeButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.swipeTutorial.buttonText")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
