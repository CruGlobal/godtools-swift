//
//  GetCurrentAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetCurrentAppLanguageUseCase {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
    }
    
    @MainActor func execute() -> AnyPublisher<AppLanguageDomainModel, Never> {
                
        return userAppLanguageRepository
            .cache
            .persistence
            .observeCollectionChangesPublisher()
            .catch { (error: Error) in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .flatMap({ (userAppLanguageChanged: Void) -> AnyPublisher<UserAppLanguageDataModel?, Never> in
              
                return self.userAppLanguageRepository
                    .getCachedLanguagePublisher()
                    .catch { (error: Error) in
                        return Just(nil)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ (userLanguage: UserAppLanguageDataModel?) -> AnyPublisher<AppLanguageDomainModel, Never> in
                
                let appLanguage: AppLanguageDomainModel = userLanguage?.languageId ?? LanguageCodeDomainModel.english.rawValue
                
                return Just(appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
