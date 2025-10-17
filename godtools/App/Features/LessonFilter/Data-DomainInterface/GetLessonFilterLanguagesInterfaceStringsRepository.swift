//
//  GetLessonFilterLanguagesInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonFilterLanguagesInterfaceStringsRepository: GetLessonFilterLanguagesInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguagesInterfaceStringsDomainModel, Never> {
        
        let localeId = translateInAppLanguage.localeId
        
        let interfaceStrings = LessonFilterLanguagesInterfaceStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LessonFilterStringKeys.navTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
