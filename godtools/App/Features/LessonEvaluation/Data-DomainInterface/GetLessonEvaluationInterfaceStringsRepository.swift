//
//  GetLessonEvaluationInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonEvaluationInterfaceStringsRepository: GetLessonEvaluationInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonEvaluationInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInAppLanguage
        
        let interfaceStrings = LessonEvaluationInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.title"),
            wasThisHelpful: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.wasThisHelpful"),
            yesButtonTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "yes"),
            noButtonTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "no"),
            shareFaith: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.shareFaith"),
            sendButtonTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.sendButtonTitle")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
