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
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolSettingsStringsDomainModel {

        let chooseParallelLanguageActionTitleKey: String = LocalizableStringKeys.toolSettingsChooseLanguageNoParallelLanguageTitle.key
        let titleKey: String = LocalizableStringKeys.toolSettingsTitle.key
        let shareLinkTitleKey: String = LocalizableStringKeys.toolSettingsOptionShareLinkTitle.key
        let screenShareTitleKey: String = LocalizableStringKeys.toolSettingsOptionScreenShareTitle.key
        let toolOptionEnableTrainingTipsKey: String = LocalizableStringKeys.toolSettingsOptionTrainingTipsShowTitle.key
        let toolOptionDisableTrainingTipsKey: String = LocalizableStringKeys.toolSettingsOptionTrainingTipsHideTitle.key
        let chooseLanguageTitleKey: String = LocalizableStringKeys.toolSettingsChooseLanguageTitle.key
        let chooseLanguageMessageKey: String = LocalizableStringKeys.toolSettingsChooseLanguageToggleMessage.key
        let shareablesTitleKey: String = LocalizableStringKeys.toolSettingsShareablesTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                chooseParallelLanguageActionTitleKey,
                titleKey,
                shareLinkTitleKey,
                screenShareTitleKey,
                toolOptionEnableTrainingTipsKey,
                toolOptionDisableTrainingTipsKey,
                chooseLanguageTitleKey,
                chooseLanguageMessageKey,
                shareablesTitleKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return ToolSettingsStringsDomainModel(
            chooseParallelLanguageActionTitle: strings[chooseParallelLanguageActionTitleKey] ?? "",
            title: strings[titleKey] ?? "",
            shareLinkTitle: strings[shareLinkTitleKey] ?? "",
            screenShareTitle: strings[screenShareTitleKey] ?? "",
            toolOptionEnableTrainingTips: strings[toolOptionEnableTrainingTipsKey] ?? "",
            toolOptionDisableTrainingTips: strings[toolOptionDisableTrainingTipsKey] ?? "",
            chooseLanguageTitle: strings[chooseLanguageTitleKey] ?? "",
            chooseLanguageMessage: strings[chooseLanguageMessageKey] ?? "",
            shareablesTitle: strings[shareablesTitleKey] ?? ""
        )
    }
}
