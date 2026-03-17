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
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LearnToShareToolStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = LearnToShareToolStringsDomainModel(
            nextTutorialItemActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "tutorial.continueButton.title.continue"),
            startTrainingActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "start_training")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
