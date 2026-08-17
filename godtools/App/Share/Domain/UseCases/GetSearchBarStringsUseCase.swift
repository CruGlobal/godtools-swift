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
    
    func execute(appLanguage: AppLanguageDomainModel) -> SearchBarStringsDomainModel {

        let cancelKey: String = LocalizableStringKeys.cancel.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                cancelKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return SearchBarStringsDomainModel(
            cancel: strings[cancelKey] ?? ""
        )
    }
}
