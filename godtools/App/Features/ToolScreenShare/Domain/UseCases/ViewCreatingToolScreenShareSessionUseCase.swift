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
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<CreatingToolScreenShareSessionDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface
            .getStringsPublisher(translateInLanguage: appLanguage)
            .map { (interfaceStrings: CreatingToolScreenShareSessionInterfaceStringsDomainModel) in
                
                CreatingToolScreenShareSessionDomainModel(
                    interfaceStrings: interfaceStrings
                )
            }
            .eraseToAnyPublisher()
    }
}
