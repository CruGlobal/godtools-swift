//
//  GetInterfaceStringInAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetInterfaceStringInAppLanguageUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface
    private let getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface, getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getInterfaceStringRepositoryInterface = getInterfaceStringRepositoryInterface
        self.getUserPreferredAppLanguageRepositoryInterface = getUserPreferredAppLanguageRepositoryInterface
    }
    
    func observeStringChangedPublisher(id: String) -> AnyPublisher<String, Never> {
        
        return getUserPreferredAppLanguageRepositoryInterface.observeLanguageChangedPublisher()
            .flatMap({ _ -> AnyPublisher<String, Never> in
                
                return self.getStringPublisher(id: id)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getStringPublisher(id: String) -> AnyPublisher<String, Never> {
        
        return getCurrentAppLanguageUseCase.getLanguagePublisher()
            .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<String, Never> in
                
                return self.getInterfaceStringRepositoryInterface.getStringPublisher(languageCode: appLanguageCode, stringId: id)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
