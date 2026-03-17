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
        
        let interfaceStrings = ResumeLessonProgressStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.resumeLessonModal.title"),
            subtitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.resumeLessonModal.subtitle"),
            startOverButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.resumeLessonModal.startOverButton"),
            continueButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.resumeLessonModal.continueButton")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
