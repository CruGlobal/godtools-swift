//
//  ViewDashboardUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewDashboardUseCase {
    
    private let getInterfaceStringsRepository: GetDashboardInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetDashboardInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDashboardDomainModel, Never> {
        
        return getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage)
            .map {
                return ViewDashboardDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
