//
//  GetLessonEvaluationStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLessonEvaluationStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> LessonEvaluationStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = LessonEvaluationStringsDomainModel(
            title: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.title"),
            wasThisHelpful: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.wasThisHelpful"),
            yesActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "yes"),
            noActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "no"),
            shareFaithReadiness: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.shareFaith"),
            sendFeedbackActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "lesson_evaluation.sendButtonTitle")
        )
        
        return strings
    }
}
