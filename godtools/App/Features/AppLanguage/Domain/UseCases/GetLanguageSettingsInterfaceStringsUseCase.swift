//
//  GetLanguageSettingsInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLanguageSettingsInterfaceStringsUseCase {
    
    private let getLanguageSettingsInterfaceStringsRepositoryInterface: GetLanguageSettingsInterfaceStringsRepositoryInterface
    
    init(getLanguageSettingsInterfaceStringsRepositoryInterface: GetLanguageSettingsInterfaceStringsRepositoryInterface) {
        
        self.getLanguageSettingsInterfaceStringsRepositoryInterface = getLanguageSettingsInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> {
        
        appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> in
                
                return self.getLanguageSettingsInterfaceStringsRepositoryInterface.getStringsPublisher(translateInAppLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
