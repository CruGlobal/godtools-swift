//
//  GetTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> TutorialStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let completeTutorialActionLocalizedStringKey: String
        
        if appLanguage == LanguageCodeDomainModel.english.value {
            completeTutorialActionLocalizedStringKey = LocalizableStringKeys.tutorialContinueButtonTitleCloseTutorial.key
        }
        else {
            completeTutorialActionLocalizedStringKey = LocalizableStringKeys.tutorialContinueButtonTitleStartUsingGodTools.key
        }
        
        let strings = TutorialStringsDomainModel(
            nextTutorialPageActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.tutorialContinueButtonTitleContinue.key),
            completeTutorialActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: completeTutorialActionLocalizedStringKey)
        )
        
        return strings
    }
}
