//
//  GetToolSettingsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolSettingsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolSettingsStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ToolSettingsStringsDomainModel(
            chooseParallelLanguageActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsChooseLanguageNoParallelLanguageTitle.key),
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsTitle.key),
            shareLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionShareLinkTitle.key),
            screenShareTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionScreenShareTitle.key),
            toolOptionEnableTrainingTips: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionTrainingTipsShowTitle.key),
            toolOptionDisableTrainingTips: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionTrainingTipsHideTitle.key),
            chooseLanguageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsChooseLanguageTitle.key),
            chooseLanguageMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsChooseLanguageToggleMessage.key),
            shareablesTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsShareablesTitle.key)
        )
        
        return strings
    }
}
