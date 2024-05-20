//
//  ViewDeleteAccountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewDeleteAccountUseCase {
    
    private let getInterfaceStringsRepository: GetDeleteAccountInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetDeleteAccountInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDeleteAccountDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInAppLanguage: appLanguage)
            .map {
                ViewDeleteAccountDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
