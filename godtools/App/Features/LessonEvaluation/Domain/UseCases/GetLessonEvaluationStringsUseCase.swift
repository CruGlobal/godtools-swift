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
    
    func execute(appLanguage: AppLanguageDomainModel) -> LessonEvaluationStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.lessonEvaluationTitle.key
        let wasThisHelpfulKey: String = LocalizableStringKeys.lessonEvaluationWasThisHelpful.key
        let yesActionTitleKey: String = LocalizableStringKeys.yes.key
        let noActionTitleKey: String = LocalizableStringKeys.no.key
        let shareFaithReadinessKey: String = LocalizableStringKeys.lessonEvaluationShareFaith.key
        let sendFeedbackActionTitleKey: String = LocalizableStringKeys.lessonEvaluationSendButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                wasThisHelpfulKey,
                yesActionTitleKey,
                noActionTitleKey,
                shareFaithReadinessKey,
                sendFeedbackActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return LessonEvaluationStringsDomainModel(
            title: strings[titleKey] ?? "",
            wasThisHelpful: strings[wasThisHelpfulKey] ?? "",
            yesActionTitle: strings[yesActionTitleKey] ?? "",
            noActionTitle: strings[noActionTitleKey] ?? "",
            shareFaithReadiness: strings[shareFaithReadinessKey] ?? "",
            sendFeedbackActionTitle: strings[sendFeedbackActionTitleKey] ?? ""
        )
    }
}
