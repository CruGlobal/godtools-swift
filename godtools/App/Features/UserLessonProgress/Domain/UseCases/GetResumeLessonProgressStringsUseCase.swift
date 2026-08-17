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
    
    func execute(appLanguage: AppLanguageDomainModel) -> ResumeLessonProgressStringsDomainModel {

        let localeId: String = appLanguage.localeId

        let titleKey: String = LocalizableStringKeys.lessonsResumeLessonModalTitle.key
        let subtitleKey: String = LocalizableStringKeys.lessonsResumeLessonModalSubtitle.key
        let startOverButtonTextKey: String = LocalizableStringKeys.lessonsResumeLessonModalStartOverButton.key
        let continueButtonTextKey: String = LocalizableStringKeys.lessonsResumeLessonModalContinueButton.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                subtitleKey,
                startOverButtonTextKey,
                continueButtonTextKey
            ],
            fetchOrder: [
                .locale(identifier: localeId),
                .english
            ],
            shouldFallbackToKey: true
        )

        return ResumeLessonProgressStringsDomainModel(
            title: strings[titleKey] ?? "",
            subtitle: strings[subtitleKey] ?? "",
            startOverButtonText: strings[startOverButtonTextKey] ?? "",
            continueButtonText: strings[continueButtonTextKey] ?? ""
        )
    }
}
