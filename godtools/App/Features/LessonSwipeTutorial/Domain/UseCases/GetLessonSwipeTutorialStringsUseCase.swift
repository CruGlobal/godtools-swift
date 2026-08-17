//
//  GetLessonSwipeTutorialStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetLessonSwipeTutorialStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) -> LessonSwipeTutorialStringsDomainModel {

        let localeId: String = translateInLanguage.localeId

        let titleKey: String = LocalizableStringKeys.lessonsSwipeTutorialTitle.key
        let closeButtonTextKey: String = LocalizableStringKeys.lessonsSwipeTutorialButtonText.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                closeButtonTextKey
            ],
            fetchOrder: [
                .locale(identifier: localeId),
                .english
            ],
            shouldFallbackToKey: true
        )

        return LessonSwipeTutorialStringsDomainModel(
            title: strings[titleKey] ?? "",
            closeButtonText: strings[closeButtonTextKey] ?? ""
        )
    }
}
