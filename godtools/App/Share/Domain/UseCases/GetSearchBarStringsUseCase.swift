//
//  GetSearchBarStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetSearchBarStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> SearchBarStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = SearchBarStringsDomainModel(
            cancel: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.cancel.key)
        )
        
        return strings
    }
}
