//
//  ViewSearchBarUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewSearchBarUseCase {
    
    private let getInterfaceStringsRepository: GetSearchBarInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetSearchBarInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewSearchBarDomainModel, Never> {
        
        return self.getInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage).map {
            
            return ViewSearchBarDomainModel(interfaceStrings: $0)
        }
        .eraseToAnyPublisher()
    }
}
