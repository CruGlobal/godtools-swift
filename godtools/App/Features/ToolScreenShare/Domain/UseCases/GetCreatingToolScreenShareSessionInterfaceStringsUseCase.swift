//
//  GetCreatingToolScreenShareSessionInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetCreatingToolScreenShareSessionInterfaceStringsUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<CreatingToolScreenShareSessionInterfaceStringsDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionInterfaceStringsDomainModel, Never> in
                
                return self.getInterfaceStringsRepositoryInterface
                    .getStringsPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
