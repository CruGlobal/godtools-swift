//
//  GetAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageRepository: GetAppLanguageRepositoryInterface {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never> {
                
        return Publishers.CombineLatest(
            userAppLanguageRepository.getLanguagePublisher(),
            userAppLanguageRepository.getLanguageChangedPublisher()
        )
        .flatMap({ (userLanguage: UserAppLanguageDataModel?, userAppLanguageChanged: Void) -> AnyPublisher<AppLanguageDomainModel, Never> in
          
            let appLanguage: AppLanguageDomainModel = userLanguage?.languageId ?? LanguageCodeDomainModel.english.rawValue
            
            return Just(appLanguage)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
