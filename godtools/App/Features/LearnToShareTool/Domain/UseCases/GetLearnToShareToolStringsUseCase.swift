//
//  GetLearnToShareToolStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLearnToShareToolStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> LearnToShareToolStringsDomainModel {

        let nextTutorialItemActionTitleKey: String = LocalizableStringKeys.tutorialContinueButtonTitleContinue.key
        let startTrainingActionTitleKey: String = LocalizableStringKeys.startTraining.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                nextTutorialItemActionTitleKey,
                startTrainingActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return LearnToShareToolStringsDomainModel(
            nextTutorialItemActionTitle: strings[nextTutorialItemActionTitleKey] ?? "",
            startTrainingActionTitle: strings[startTrainingActionTitleKey] ?? ""
        )
    }
}
