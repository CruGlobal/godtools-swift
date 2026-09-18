//
//  SetAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SetAppLanguageUseCase: Sendable {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    private let languagesRepository: LanguagesRepository
    
    init(
        userAppLanguageRepository: UserAppLanguageRepository,
        userToolFilterSettingsRepository: UserToolFilterSettingsRepository,
        languagesRepository: LanguagesRepository
    ) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
        self.languagesRepository = languagesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async throws -> AppLanguageDomainModel {
        
        if let languageModelId = languagesRepository.getLanguageByCode(code: appLanguage)?.id {
            
            try await userToolFilterSettingsRepository.storeSettingValue(
                settingType: .lessonsLanguageFilter,
                value: languageModelId
            )
        }
        
        try await userAppLanguageRepository
            .storeLanguage(appLanguageId: appLanguage)
        
        return appLanguage
    }
}
