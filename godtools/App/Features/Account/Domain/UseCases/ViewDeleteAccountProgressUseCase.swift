//
//  ViewDeleteAccountProgressUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewDeleteAccountProgressUseCase {
    
    private let getInterfaceStringsRepository: GetDeleteAccountProgressInterfaceStringsInterface
    
    init(getInterfaceStringsRepository: GetDeleteAccountProgressInterfaceStringsInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDeleteAccountProgressDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInAppLanguage: appLanguage)
            .map {
                ViewDeleteAccountProgressDomainModel(
                    interfaceStrings: $0
                )
            }
            .eraseToAnyPublisher()
    }
}
