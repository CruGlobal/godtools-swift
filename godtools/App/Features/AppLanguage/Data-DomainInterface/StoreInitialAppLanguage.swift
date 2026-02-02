//
//  StoreInitialAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreInitialAppLanguage: StoreInitialAppLanguageInterface {
    
    private let deviceSystemLanguage: DeviceSystemLanguageInterface
    private let userAppLanguageRepository: UserAppLanguageRepository
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(deviceSystemLanguage: DeviceSystemLanguageInterface, userAppLanguageRepository: UserAppLanguageRepository, appLanguagesRepository: AppLanguagesRepository) {
        
        self.deviceSystemLanguage = deviceSystemLanguage
        self.userAppLanguageRepository = userAppLanguageRepository
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func storeInitialAppLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Error> {
        
        return Publishers.CombineLatest(
            userAppLanguageRepository
                .getCachedLanguagePublisher(),
            appLanguagesRepository
                .getLanguagesPublisher()
        )
        .flatMap({ (userAppLanguage: UserAppLanguageDataModel?, appLanguages: [AppLanguageDataModel]) -> AnyPublisher<AppLanguageDomainModel, Error> in
            
            if let userAppLanguage = userAppLanguage {
                return Just(userAppLanguage.languageId)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            let deviceLocale: Locale = self.deviceSystemLanguage.getLocale()
            
            let deviceAppLanguage: AppLanguageDataModel? = appLanguages.first(where: {
                $0.localeId == deviceLocale.identifier
            })
                        
            let appLanguageToStore: AppLanguageDomainModel
            
            if let deviceAppLanguage = deviceAppLanguage {
                appLanguageToStore = deviceAppLanguage.languageId
            }
            else {
                appLanguageToStore = LanguageCodeDomainModel.english.rawValue
            }
            
            return self.userAppLanguageRepository
                .storeLanguagePublisher(
                    appLanguageId: appLanguageToStore
                )
                .map { _ in
                    appLanguageToStore
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
