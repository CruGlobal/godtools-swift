//
//  ViewAppLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewAppLanguagesUseCase {
    
    private let getInterfaceStringsRepository: GetAppLanguagesInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetAppLanguagesInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewAppLanguagesDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .map {
                return ViewAppLanguagesDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
