//
//  GetShareToolQRCodeStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetShareToolQRCodeStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ShareToolQRCodeStringsDomainModel {

        let messageKey: String = LocalizableStringKeys.shareToolQrCodeMessage.key
        let closeActionTitleKey: String = LocalizableStringKeys.toolScreenShareQrCodeCloseButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                messageKey,
                closeActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ShareToolQRCodeStringsDomainModel(
            message: strings[messageKey] ?? "",
            closeActionTitle: strings[closeActionTitleKey] ?? ""
        )
    }
}
