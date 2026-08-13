//
//  GetToolSettingsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolSettingsStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> ToolSettingsStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ToolSettingsStringsDomainModel(
            chooseParallelLanguageActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsChooseLanguageNoParallelLanguageTitle.key),
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsTitle.key),
            shareLinkTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionShareLinkTitle.key),
            screenShareTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionScreenShareTitle.key),
            toolOptionEnableTrainingTips: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionTrainingTipsShowTitle.key),
            toolOptionDisableTrainingTips: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsOptionTrainingTipsHideTitle.key),
            chooseLanguageTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsChooseLanguageTitle.key),
            chooseLanguageMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsChooseLanguageToggleMessage.key),
            shareablesTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolSettingsShareablesTitle.key)
        )
        
        return strings
    }
}
