//
//  GetUserPersonalizedLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserPersonalizedLessonFilterLanguageUseCase: Sendable {
    
    private let languagesRepository: LanguagesRepository
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    private let mapLanguageToPersonalizedLessonFilterLanguage: MapLanguageToPersonalizedLessonFilterLanguage
    
    init(
        languagesRepository: LanguagesRepository,
        userToolFilterSettingsRepository: UserToolFilterSettingsRepository,
        mapLanguageToPersonalizedLessonFilterLanguage: MapLanguageToPersonalizedLessonFilterLanguage
    ) {
        
        self.languagesRepository = languagesRepository
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
        self.mapLanguageToPersonalizedLessonFilterLanguage = mapLanguageToPersonalizedLessonFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<PersonalizedLessonFilterLanguageDomainModel?, Error> {
        
        return Publishers.CombineLatest(
            languagesRepository.observeCollectionChangesPublisher(),
            userToolFilterSettingsRepository
                .observeSettingValueChangedPublisher(settingType: .personalizedLessonsLanguageFilter)
        )
        .map { (languagesChanged: Void, userFilterLanguageId: String?) in
            
            return self.getFilterLanguage(
                userFilterLanguageId: userFilterLanguageId,
                appLanguage: appLanguage
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func getFilterLanguage(userFilterLanguageId: String?, appLanguage: AppLanguageDomainModel) -> PersonalizedLessonFilterLanguageDomainModel? {
        
        if let userFilterLanguageId = userFilterLanguageId,
           let language = languagesRepository.getLanguageById(id: userFilterLanguageId) {
            
            return mapLanguageToPersonalizedLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        else if let language = languagesRepository.getLanguageByCode(code: appLanguage) {
            
            return mapLanguageToPersonalizedLessonFilterLanguage.map(
                language: language,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return nil
    }
}
