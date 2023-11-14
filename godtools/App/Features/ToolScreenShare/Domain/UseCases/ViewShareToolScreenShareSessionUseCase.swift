//
//  ViewShareToolScreenShareSessionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewShareToolScreenShareSessionUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetShareToolScreenShareSessionInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetShareToolScreenShareSessionInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func viewPublisher(appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<ShareToolScreenShareSessionDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface
            .getStringsPublisher(translateInLanguage: appLanguage)
            .flatMap({ (interfaceStrings: ShareToolScreenShareSessionInterfaceStringsDomainModel) -> AnyPublisher<ShareToolScreenShareSessionDomainModel, Never> in
                
                let domainModel = ShareToolScreenShareSessionDomainModel(interfaceStrings: interfaceStrings)
                
                return Just(domainModel)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
