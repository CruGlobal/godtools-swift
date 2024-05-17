//
//  ViewAccountUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewAccountUseCase {
    
    private let getInterfaceStringsRepository: GetAccountInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetAccountInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewAccountDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInAppLanguage: appLanguage)
            .map { interfaceStrings in
                
                return ViewAccountDomainModel(
                    interfaceStrings: interfaceStrings
                )
            }
            .eraseToAnyPublisher()
    }
}
