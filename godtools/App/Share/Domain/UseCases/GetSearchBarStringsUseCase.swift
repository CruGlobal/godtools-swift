//
//  GetSearchBarStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetSearchBarStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> SearchBarStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = SearchBarStringsDomainModel(
            cancel: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "cancel")
        )
        
        return strings
    }
}
