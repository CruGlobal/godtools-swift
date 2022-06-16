//
//  SharedUseCaseType+GetToolCategoryNameUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension SharedUseCaseType {
    
    func getToolCategoryName(resource: ResourceModel, languageSettingsService: LanguageSettingsService, localizationService: LocalizationServices) -> String? {

        let bundle: Bundle = getPrimaryLanguageBundle(languageSettingsService: languageSettingsService, localizationService: localizationService)
        
        let localizedKey: String = "tool_category_\(resource.attrCategory)"
        
        return localizationService.stringForBundle(bundle: bundle, key: localizedKey)
    }
}

