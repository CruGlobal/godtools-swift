//
//  GetResumeLessonProgressStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetResumeLessonProgressStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ResumeLessonProgressStringsDomainModel, Never> {
        
        let localeId: String = appLanguage.localeId
        
        let strings = ResumeLessonProgressStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalTitle.key),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalSubtitle.key),
            startOverButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalStartOverButton.key),
            continueButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.lessonsResumeLessonModalContinueButton.key)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
