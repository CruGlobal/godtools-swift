//
//  GetMenuInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetMenuInterfaceStringsUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetMenuInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetMenuInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguageChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<MenuInterfaceStringsDomainModel, Never> {
        
        return appLanguageChangedPublisher
            .flatMap({ (appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<MenuInterfaceStringsDomainModel, Never> in
                
                return self.getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
