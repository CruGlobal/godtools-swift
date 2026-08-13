//
//  GetLessonEvaluationStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLessonEvaluationStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> LessonEvaluationStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = LessonEvaluationStringsDomainModel(
            title: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonEvaluationTitle.key),
            wasThisHelpful: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonEvaluationWasThisHelpful.key),
            yesActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.yes.key),
            noActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.no.key),
            shareFaithReadiness: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonEvaluationShareFaith.key),
            sendFeedbackActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonEvaluationSendButtonTitle.key)
        )
        
        return strings
    }
}
