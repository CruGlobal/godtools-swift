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
    
    func execute(appLanguage: AppLanguageDomainModel) async -> TutorialStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let completeTutorialActionLocalizedStringKey: String
        
        if appLanguage == LanguageCodeDomainModel.english.value {
            completeTutorialActionLocalizedStringKey = LocalizableStringKeys.tutorialContinueButtonTitleCloseTutorial.key
        }
        else {
            completeTutorialActionLocalizedStringKey = LocalizableStringKeys.tutorialContinueButtonTitleStartUsingGodTools.key
        }
        
        let strings = TutorialStringsDomainModel(
            nextTutorialPageActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.tutorialContinueButtonTitleContinue.key),
            completeTutorialActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: completeTutorialActionLocalizedStringKey)
        )
        
        return strings
    }
}
