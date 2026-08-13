//
//  GetDeleteAccountProgressStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetDeleteAccountProgressStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> DeleteAccountProgressStringsDomainModel {
        
        let strings = DeleteAccountProgressStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.deleteAccountProgressTitle.key)
        )
        
        return strings
    }
}
