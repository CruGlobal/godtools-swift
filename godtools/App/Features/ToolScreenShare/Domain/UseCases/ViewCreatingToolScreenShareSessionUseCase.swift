//
//  ViewCreatingToolScreenShareSessionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewCreatingToolScreenShareSessionUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func viewPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<CreatingToolScreenShareSessionDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionInterfaceStringsDomainModel, Never> in
                
                return self.getInterfaceStringsRepositoryInterface
                    .getStringsPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (interfaceStrings: CreatingToolScreenShareSessionInterfaceStringsDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionDomainModel, Never> in
                
                let domainModel = CreatingToolScreenShareSessionDomainModel(interfaceStrings: interfaceStrings)
                
                return Just(domainModel)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
