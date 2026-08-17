//
//  GetTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetTutorialStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> TutorialStringsDomainModel {

        let nextTutorialPageActionTitleKey: String = LocalizableStringKeys.tutorialContinueButtonTitleContinue.key

        let completeTutorialActionLocalizedStringKey: String

        if appLanguage == LanguageCodeDomainModel.english.value {
            completeTutorialActionLocalizedStringKey = LocalizableStringKeys.tutorialContinueButtonTitleCloseTutorial.key
        }
        else {
            completeTutorialActionLocalizedStringKey = LocalizableStringKeys.tutorialContinueButtonTitleStartUsingGodTools.key
        }

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                nextTutorialPageActionTitleKey,
                completeTutorialActionLocalizedStringKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return TutorialStringsDomainModel(
            nextTutorialPageActionTitle: strings[nextTutorialPageActionTitleKey] ?? "",
            completeTutorialActionTitle: strings[completeTutorialActionLocalizedStringKey] ?? ""
        )
    }
}
