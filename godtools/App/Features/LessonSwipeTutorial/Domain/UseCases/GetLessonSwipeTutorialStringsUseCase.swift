//
//  GetLessonSwipeTutorialStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetLessonSwipeTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> LessonSwipeTutorialStringsDomainModel {
        
        let localeId: String = translateInLanguage.localeId
        
        let strings = LessonSwipeTutorialStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsSwipeTutorialTitle.key),
            closeButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsSwipeTutorialButtonText.key)
        )
        
        return strings
    }
}
