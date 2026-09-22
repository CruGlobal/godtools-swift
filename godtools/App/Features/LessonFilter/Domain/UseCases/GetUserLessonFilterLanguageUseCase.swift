//
//  GetUserLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserLessonFilterLanguageUseCase: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    private let mapLanguageToLessonFilterLanguage: MapLanguageToLessonFilterLanguage
    
    init(
        languagesRepository: LanguagesRepository,
        userToolFilterSettingsRepository: UserToolFilterSettingsRepository,
        mapLanguageToLessonFilterLanguage: MapLanguageToLessonFilterLanguage
    ) {
        
        self.languagesRepository = languagesRepository
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
        self.mapLanguageToLessonFilterLanguage = mapLanguageToLessonFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguageDomainModel?, Error> {
        
        return Publishers.CombineLatest(
            languagesRepository.observeCollectionChangesPublisher(),
            userToolFilterSettingsRepository
                .observeSettingValueChangedPublisher(settingType: .lessonsLanguageFilter)
        )
        .map { (languagesChanged: Void, userFilterLanguageId: String?) in
            
            return self.getUserLessonFilterLanguage(
                userFilterLanguageId: userFilterLanguageId,
                appLanguage: appLanguage
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func getUserLessonFilterLanguage(userFilterLanguageId: String?, appLanguage: AppLanguageDomainModel) -> LessonFilterLanguageDomainModel? {
        
        if let userFilterLanguageId = userFilterLanguageId,
           let language = languagesRepository.getLanguageById(id: userFilterLanguageId) {
            
            return mapLanguageToLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        else if let language = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            return mapLanguageToLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return nil
    }
}
