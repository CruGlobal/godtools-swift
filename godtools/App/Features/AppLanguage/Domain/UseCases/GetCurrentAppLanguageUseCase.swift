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
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .map { _ in
                
                let userLanguage: UserAppLanguageDataModel? = self.userAppLanguageRepository.getLanguage()
                
                let appLanguage: AppLanguageDomainModel = userLanguage?.languageId ?? LanguageCodeDomainModel.english.rawValue
                
                return appLanguage
            }
            .eraseToAnyPublisher()
    }
}
