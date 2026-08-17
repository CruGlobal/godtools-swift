//
//  GetCreatingToolScreenShareSessionTimedOutStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetCreatingToolScreenShareSessionTimedOutStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> CreatingToolScreenShareSessionTimedOutStringsDomainModel {

        let acceptActionTitleKey: String = LocalizableStringKeys.ok.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                acceptActionTitleKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return CreatingToolScreenShareSessionTimedOutStringsDomainModel(
            title: "Timed Out",
            message: "Timed out creating the session for tool screen share.",
            acceptActionTitle: strings[acceptActionTitleKey] ?? ""
        )
    }
}
