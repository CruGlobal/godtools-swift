//
//  GetAppLanguageNameUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageNameUseCase {
    
    private let getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface
    
    init(getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface) {
        
        self.getAppLanguageNameRepositoryInterface = getAppLanguageNameRepositoryInterface
    }
    
    func getLanguageNamePublisher(language: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> {
        
        return getAppLanguageNameRepositoryInterface.getLanguageNamePublisher(appLanguageCode: language, translateInLanguage: language)
            .eraseToAnyPublisher()
    }
}
