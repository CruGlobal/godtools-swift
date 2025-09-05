//
//  GetDeferredDeepLinkModalInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDeferredDeepLinkModalInterfaceStringsUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetDeferredDeepLinkModalInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetDeferredDeepLinkModalInterfaceStringsRepositoryInterface) {
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<DeferredDeepLinkModalInterfaceStringsDomainModel, Never> {
        
        return getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInAppLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
