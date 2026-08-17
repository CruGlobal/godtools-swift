//
//  GetReviewShareShareableStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetReviewShareShareableStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ReviewShareShareableStringsDomainModel {

        let shareActionTitleKey: String = LocalizableStringKeys.toolSettingsShareImagePreviewShareImageButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                shareActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ReviewShareShareableStringsDomainModel(
            shareActionTitle: strings[shareActionTitleKey] ?? ""
        )
    }
}
