//
//  GetToolSettingsToolLanguagesListStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolSettingsToolLanguagesListStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolSettingsToolLanguagesListStringsDomainModel {

        let deleteParallelLanguageActionTitleKey: String = LocalizableStringKeys.toolSettingsLanguagesListDeleteLanguageTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                deleteParallelLanguageActionTitleKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return ToolSettingsToolLanguagesListStringsDomainModel(
            deleteParallelLanguageActionTitle: strings[deleteParallelLanguageActionTitleKey] ?? ""
        )
    }
}
