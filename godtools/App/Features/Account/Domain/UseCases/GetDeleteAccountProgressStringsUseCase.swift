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
    
    func execute(appLanguage: AppLanguageDomainModel) -> DeleteAccountProgressStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.deleteAccountProgressTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return DeleteAccountProgressStringsDomainModel(
            title: strings[titleKey] ?? ""
        )
    }
}
