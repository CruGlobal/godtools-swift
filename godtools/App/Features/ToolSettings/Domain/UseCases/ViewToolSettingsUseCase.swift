//
//  ViewToolSettingsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolSettingsUseCase {
    
    private let getInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolSettingsDomainModel, Never> {
        
        return getInterfaceStringsRepository
            .getStringsPublisher(translateInLanguage: appLanguage)
            .flatMap({ (interfaceStrings: ToolSettingsInterfaceStringsDomainModel) -> AnyPublisher<ViewToolSettingsDomainModel, Never> in
                
                let domainModel = ViewToolSettingsDomainModel(
                    interfaceStrings: interfaceStrings
                )
                
                return Just(domainModel)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
