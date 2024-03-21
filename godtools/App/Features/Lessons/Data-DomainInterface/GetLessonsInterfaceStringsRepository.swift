//
//  GetLessonsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsInterfaceStringsRepository: GetLessonsInterfaceStringsRepositoryInterface {
 
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonsInterfaceStringsDomainModel, Never> {
     
        let localeId: String = translateInLanguage
        
        let interfaceStrings = LessonsInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.pageTitle"),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.pageSubtitle")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
