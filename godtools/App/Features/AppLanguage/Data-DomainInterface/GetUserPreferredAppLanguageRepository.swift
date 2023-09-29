//
//  GetUserPreferredAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserPreferredAppLanguageRepository: GetUserPreferredAppLanguageRepositoryInterface {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageCodeDomainModel?, Never> {
        
        return userAppLanguageRepository.getLanguagePublisher()
            .map {
                return $0?.languageCode
            }
            .eraseToAnyPublisher()
    }
}
