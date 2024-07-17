//
//  GetCurrentAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetCurrentAppLanguageUseCase {
    
    private let getAppLanguageRepository: GetAppLanguageRepositoryInterface
        
    init(getAppLanguageRepository: GetAppLanguageRepositoryInterface) {
        
        self.getAppLanguageRepository = getAppLanguageRepository
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        return getAppLanguageRepository
            .getLanguagePublisher()
            .eraseToAnyPublisher()
    }
}
