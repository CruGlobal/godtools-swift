//
//  ViewLanguageSettingsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLanguageSettingsUseCase {
    
    private let getInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLanguageSettingsDomainModel, Never> {
        
        return self.getInterfaceStringsRepository
            .getStringsPublisher(translateInAppLanguage: appLanguage)
            .map {
                
                return ViewLanguageSettingsDomainModel(interfaceStrings: $0)
            }
            .eraseToAnyPublisher()
    }
}
