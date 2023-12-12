//
//  GetLearnToShareToolInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLearnToShareToolInterfaceStringsRepository: GetLearnToShareToolInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LearnToShareToolInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = LearnToShareToolInterfaceStringsDomainModel(
            nextTutorialItemActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.continueButton.title.continue"),
            startTrainingActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "start_training")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
