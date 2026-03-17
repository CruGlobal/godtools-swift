//
//  GetLessonFilterLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLessonFilterLanguagesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguagesStringsDomainModel, Never> {
        
        let localeId = appLanguage.localeId
        
        let strings = LessonFilterLanguagesStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LessonFilterStringKeys.navTitle.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
