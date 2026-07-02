//
//  GetToolListItemStrings.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetToolListItemStrings {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStrings(appLanguage: AppLanguageDomainModel) -> ToolListItemStringsDomainModel {
        
        let strings = ToolListItemStringsDomainModel(
            openToolActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.open.key),
            openToolDetailsActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.favoritesFavoriteLessonsDetails.key)
        )
        
        return strings
    }
}
