//
//  GetUserPersonalizedToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserPersonalizedToolFilterLanguageUseCase: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    private let mapLanguageToPersonalizedToolFilterLanguage: MapLanguageToPersonalizedToolFilterLanguage
    
    init(
        languagesRepository: LanguagesRepository,
        userToolFilterSettingsRepository: UserToolFilterSettingsRepository,
        mapLanguageToPersonalizedToolFilterLanguage: MapLanguageToPersonalizedToolFilterLanguage
    ) {
        
        self.languagesRepository = languagesRepository
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
        self.mapLanguageToPersonalizedToolFilterLanguage = mapLanguageToPersonalizedToolFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<PersonalizedToolFilterLanguageDomainModel?, Error> {
        
        return Publishers.CombineLatest(
            languagesRepository.observeCollectionChangesPublisher(),
            userToolFilterSettingsRepository
                .observeSettingValueChangedPublisher(settingType: .personalizedToolsLanguageFilter)
        )
        .map { (languagesChanged: Void, userFilterLanguageId: String?) in
            
            return self.getFilterLanguage(
                userFilterLanguageId: userFilterLanguageId,
                appLanguage: appLanguage
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func getFilterLanguage(userFilterLanguageId: String?, appLanguage: AppLanguageDomainModel) -> PersonalizedToolFilterLanguageDomainModel? {
        
        if let userFilterLanguageId = userFilterLanguageId,
           let language = languagesRepository.getLanguageById(id: userFilterLanguageId) {
            
            return mapLanguageToPersonalizedToolFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        else if let language = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            return mapLanguageToPersonalizedToolFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return nil
    }
}
