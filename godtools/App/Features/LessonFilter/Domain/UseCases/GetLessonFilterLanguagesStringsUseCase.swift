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
    
    func execute(appLanguage: AppLanguageDomainModel) -> LessonFilterLanguagesStringsDomainModel {

        let localeId: String = appLanguage.localeId

        let navTitleKey: String = LocalizableStringKeys.lessonsFilterLanguageNavTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return LessonFilterLanguagesStringsDomainModel(
            navTitle: strings[navTitleKey] ?? ""
        )
    }
}
