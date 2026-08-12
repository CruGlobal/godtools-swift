//
//  GetDashboardStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetDashboardStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(translateInLanguage: AppLanguageDomainModel) async -> DashboardStringsDomainModel {
        
        let localeId: String = translateInLanguage
        
        let strings = DashboardStringsDomainModel(
            lessonsActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolMenuItemLessons.key),
            favoritesActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.myTools.key),
            toolsActionTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolMenuItemTools.key)
        )
        
        return strings
    }
}
