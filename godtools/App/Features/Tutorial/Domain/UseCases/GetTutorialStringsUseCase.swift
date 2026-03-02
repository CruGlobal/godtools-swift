//
//  GetTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<TutorialStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let completeTutorialActionLocalizedStringKey: String
        
        if appLanguage == LanguageCodeDomainModel.english.value {
            completeTutorialActionLocalizedStringKey = "tutorial.continueButton.title.closeTutorial"
        }
        else {
            completeTutorialActionLocalizedStringKey = "tutorial.continueButton.title.startUsingGodTools"
        }
        
        let interfaceStrings = TutorialStringsDomainModel(
            nextTutorialPageActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "tutorial.continueButton.title.continue"),
            completeTutorialActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: completeTutorialActionLocalizedStringKey)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
