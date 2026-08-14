//
//  GetResumeLessonProgressStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetResumeLessonProgressStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> ResumeLessonProgressStringsDomainModel {
        
        let localeId: String = appLanguage.localeId
        
        let strings = ResumeLessonProgressStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalTitle.key),
            subtitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalSubtitle.key),
            startOverButtonText: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalStartOverButton.key),
            continueButtonText: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalContinueButton.key)
        )
        
        return strings
    }
}
