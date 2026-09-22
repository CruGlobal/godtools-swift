//
//  GetUserToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserToolFilterLanguageUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    private let getToolFilterLanguage: GetToolFilterLanguage
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository, getToolFilterLanguage: GetToolFilterLanguage) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
        self.getToolFilterLanguage = getToolFilterLanguage
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<ToolFilterLanguageDomainModel, Never> {
        
        return userToolFilterSettingsRepository
            .observeSettingValueChangedPublisher(settingType: .toolsLanguageFilter)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.global())
            .map { (languageId: String?) in
                return self.getToolFilterLanguage(languageId: languageId, appLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private func getToolFilterLanguage(languageId: String?, appLanguage: AppLanguageDomainModel) -> ToolFilterLanguageDomainModel {
        
        if let languageId = languageId,
            let languageFilter = getToolFilterLanguage.getLanguageFilter(
                languageId: languageId,
                translatedInAppLanguage: appLanguage
            ) {
            
            return languageFilter
        }
        
        return getToolFilterLanguage.getAnyLanguageFilter(translatedInAppLanguage: appLanguage)
    }
}
