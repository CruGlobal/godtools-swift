//
//  ViewToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolsUseCase {
    
    private let getInterfaceStringsRepository: GetToolsInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolsInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolsDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .map {
                
                ViewToolsDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
