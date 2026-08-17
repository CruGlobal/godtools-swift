//
//  GetShareGodToolsStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetShareGodToolsStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ShareGodToolsStringsDomainModel {

        let shareMessageKey: String = LocalizableStringKeys.shareGodToolsShareSheetText.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                shareMessageKey
            ],
            fetchOrder: [
                .locale(identifier: appLanguage),
                .english
            ],
            shouldFallbackToKey: true
        )

        return ShareGodToolsStringsDomainModel(
            shareMessage: strings[shareMessageKey] ?? ""
        )
    }
}
