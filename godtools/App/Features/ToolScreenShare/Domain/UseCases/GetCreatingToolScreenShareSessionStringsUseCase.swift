//
//  GetCreatingToolScreenShareSessionStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetCreatingToolScreenShareSessionStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> CreatingToolScreenShareSessionStringsDomainModel {

        let creatingSessionMessageKey: String = LocalizableStringKeys.loadToolRemoteSessionMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                creatingSessionMessageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return CreatingToolScreenShareSessionStringsDomainModel(
            creatingSessionMessage: strings[creatingSessionMessageKey] ?? ""
        )
    }
}
