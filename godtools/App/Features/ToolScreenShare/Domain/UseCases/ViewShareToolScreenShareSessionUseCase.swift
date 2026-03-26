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
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolScreenShareSessionDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface
            .getStringsPublisher(translateInLanguage: appLanguage)
            .flatMap({ (strings: ShareToolScreenShareSessionInterfaceStringsDomainModel) -> AnyPublisher<ShareToolScreenShareSessionDomainModel, Never> in
                
                let domainModel = ShareToolScreenShareSessionDomainModel(strings: strings)
                
                return Just(domainModel)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
