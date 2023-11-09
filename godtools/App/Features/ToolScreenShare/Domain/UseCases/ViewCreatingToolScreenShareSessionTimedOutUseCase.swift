//
//  ViewCreatingToolScreenShareSessionTimedOutUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewCreatingToolScreenShareSessionTimedOutUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func viewPublisher(appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionTimedOutDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface
            .getStringsPublisher(translateInLanguage: appLanguage)
            .flatMap({ (interfaceStrings: CreatingToolScreenShareSessionTimedOutInterfaceStringsDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionTimedOutDomainModel, Never> in
                
                let domainModel = CreatingToolScreenShareSessionTimedOutDomainModel(interfaceStrings: interfaceStrings)
                
                return Just(domainModel)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
