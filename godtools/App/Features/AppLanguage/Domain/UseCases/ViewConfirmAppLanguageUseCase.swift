//
//  ViewConfirmAppLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewConfirmAppLanguageUseCase {
    
    private let getConfirmAppLanguageInterfaceStringsRepository: GetConfirmAppLanguageInterfaceStringsRepositoryInterface
    
    init(getConfirmAppLanguageInterfaceStringsRepository: GetConfirmAppLanguageInterfaceStringsRepositoryInterface) {
        
        self.getConfirmAppLanguageInterfaceStringsRepository = getConfirmAppLanguageInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel, selectedLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewConfirmAppLanguageDomainModel, Never> {
        
        return getConfirmAppLanguageInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage, selectedLanguage: selectedLanguage)
            .map { interfaceStrings in
                
                return ViewConfirmAppLanguageDomainModel(interfaceStrings: interfaceStrings)
            }
            .eraseToAnyPublisher()
    }
}
