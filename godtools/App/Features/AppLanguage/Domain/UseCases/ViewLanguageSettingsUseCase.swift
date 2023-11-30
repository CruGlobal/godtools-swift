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
    
    func viewPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<ViewLanguageSettingsDomainModel, Never> {
        
        appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLanguageSettingsDomainModel, Never> in
                
                return self.getInterfaceStringsRepository
                    .getStringsPublisher(translateInAppLanguage: appLanguage)
                    .map {
                        
                        return ViewLanguageSettingsDomainModel(interfaceStrings: $0)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
