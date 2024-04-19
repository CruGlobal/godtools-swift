//
//  ViewShareGodToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewShareGodToolsUseCase {
    
    private let getInterfaceStringsRepository: GetShareGodToolsInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetShareGodToolsInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewShareGodToolsDomainModel, Never> {
        
        return getInterfaceStringsRepository.getInterfaceStringsPublisher(translateInLanguage: appLanguage)
            .map {
                return ViewShareGodToolsDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
