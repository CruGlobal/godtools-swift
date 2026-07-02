//
//  StoreInitialAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class StoreInitialAppLanguageUseCase {
    
    private let deviceSystemLanguage: DeviceSystemLanguageInterface
    private let userAppLanguageRepository: UserAppLanguageRepository
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(
        deviceSystemLanguage: DeviceSystemLanguageInterface,
        userAppLanguageRepository: UserAppLanguageRepository,
        appLanguagesRepository: AppLanguagesRepository
    ) {
        
        self.deviceSystemLanguage = deviceSystemLanguage
        self.userAppLanguageRepository = userAppLanguageRepository
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    @MainActor func execute() -> AnyPublisher<AppLanguageDomainModel, Error> {
        
        return appLanguagesRepository
            .observeCollectionChangesPublisher()
            .flatMap { _ in
                
                return AnyPublisher() {
                    try await self.asyncExecute()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute() async throws -> AppLanguageDomainModel {
        
        let userAppLanguage: UserAppLanguageDataModel? = userAppLanguageRepository.getLanguage()
        
        if let userAppLanguage = userAppLanguage {
            return userAppLanguage.languageId
        }
        
        let appLanguages: [AppLanguageDataModel] = try await appLanguagesRepository.getLanguages()

        let deviceLocale: Locale = deviceSystemLanguage.getLocale()
        
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
        
        try await userAppLanguageRepository.storeLanguage(appLanguageId: appLanguageToStore)
        
        return appLanguageToStore
    }
}
