//
//  GetToolSettingsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsInterfaceStringsRepository: GetToolSettingsInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = ToolSettingsInterfaceStringsDomainModel(
            chooseParallelLanguageActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.chooseLanguage.noParallelLanguageTitle"),
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.title"),
            toolOptionShareLink: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.shareLink.title"),
            toolOptionScreenShare: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.screenShare.title"),
            toolOptionEnableTrainingTips: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.option.trainingTips.show.title"),
            languageSelectionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.chooseLanguage.title"),
            languageSelectionMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.chooseLanguage.toggleMessage"),
            relatedGraphicsTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.shareables.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
