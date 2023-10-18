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
    
    func getStringsPublisher(appLanguageChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> {
        
        appLanguageChangedPublisher
            .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<LanguageSettingsInterfaceStringsDomainModel, Never> in
                
                return self.getLanguageSettingsInterfaceStringsRepositoryInterface.getStringsPublisher(translateInAppLanguage: appLanguageCode)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
