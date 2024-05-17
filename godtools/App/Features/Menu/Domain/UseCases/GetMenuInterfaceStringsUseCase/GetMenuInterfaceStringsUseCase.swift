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
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<MenuInterfaceStringsDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface
            .getStringsPublisher(translateInLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
