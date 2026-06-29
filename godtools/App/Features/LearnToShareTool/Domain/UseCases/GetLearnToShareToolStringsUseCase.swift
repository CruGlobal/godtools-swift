//
//  GetLearnToShareToolStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetLearnToShareToolStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> LearnToShareToolStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = LearnToShareToolStringsDomainModel(
            nextTutorialItemActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.tutorialContinueButtonTitleContinue.key),
            startTrainingActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.startTraining.key)
        )
        
        return strings
    }
}
