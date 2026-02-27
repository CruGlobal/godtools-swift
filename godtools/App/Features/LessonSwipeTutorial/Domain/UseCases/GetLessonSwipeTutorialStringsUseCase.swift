//
//  GetLessonSwipeTutorialStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLessonSwipeTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonSwipeTutorialStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage.localeId
        
        let strings = LessonSwipeTutorialStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.swipeTutorial.title"),
            closeButtonText: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "lessons.swipeTutorial.buttonText")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
