//
//  GetTutorialInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetTutorialInterfaceStringsRepository: GetTutorialInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<TutorialInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let completeTutorialActionLocalizedStringKey: String
        
        if translateInLanguage == LanguageCodeDomainModel.english.value {
            completeTutorialActionLocalizedStringKey = "tutorial.continueButton.title.closeTutorial"
        }
        else {
            completeTutorialActionLocalizedStringKey = "tutorial.continueButton.title.startUsingGodTools"
        }
        
        let interfaceStrings = TutorialInterfaceStringsDomainModel(
            nextTutorialPageActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "tutorial.continueButton.title.continue"),
            completeTutorialActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: completeTutorialActionLocalizedStringKey)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
