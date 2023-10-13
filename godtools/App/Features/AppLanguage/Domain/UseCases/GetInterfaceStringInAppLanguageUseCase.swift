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
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getInterfaceStringRepositoryInterface = getInterfaceStringRepositoryInterface
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
