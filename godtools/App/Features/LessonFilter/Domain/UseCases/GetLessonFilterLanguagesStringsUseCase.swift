//
//  GetLessonFilterLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetLessonFilterLanguagesStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> LessonFilterLanguagesStringsDomainModel {
        
        let localeId = appLanguage.localeId
        
        let strings = LessonFilterLanguagesStringsDomainModel(
            navTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsFilterLanguageNavTitle.key)
        )
        
        return strings
    }
}
