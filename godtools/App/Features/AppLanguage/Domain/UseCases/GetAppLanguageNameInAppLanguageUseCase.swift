//
//  GetAppLanguageNameInAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageNameInAppLanguageUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguageNameRepositoryInterface = getAppLanguageNameRepositoryInterface
    }
    
    func getLanguageNamePublisher(language: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> {
        
        return getCurrentAppLanguageUseCase.getLanguagePublisher()
            .flatMap({ (currentAppLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> in
                
                return self.getAppLanguageNameRepositoryInterface.getLanguageNamePublisher(appLanguageCode: language, translateInLanguage: currentAppLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
