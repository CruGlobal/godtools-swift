//
//  GetToolSettingsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolSettingsStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = ToolSettingsStringsDomainModel(
            chooseParallelLanguageActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.chooseLanguage.noParallelLanguageTitle"),
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.title"),
            shareLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.shareLink.title"),
            screenShareTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.screenShare.title"),
            toolOptionEnableTrainingTips: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.trainingTips.show.title"),
            toolOptionDisableTrainingTips: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.trainingTips.hide.title"),
            chooseLanguageTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.chooseLanguage.title"),
            chooseLanguageMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.chooseLanguage.toggleMessage"),
            shareablesTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.shareables.title")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
