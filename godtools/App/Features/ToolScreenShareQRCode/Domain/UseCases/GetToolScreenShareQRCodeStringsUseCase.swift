//
//  GetToolScreenShareQRCodeStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareQRCodeStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolScreenShareQRCodeStringsDomainModel {

        let qrCodeDescriptionKey: String = LocalizableStringKeys.toolScreenShareQrCodeDescription.key
        let closeButtonTitleKey: String = LocalizableStringKeys.toolScreenShareQrCodeCloseButtonTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                qrCodeDescriptionKey,
                closeButtonTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ToolScreenShareQRCodeStringsDomainModel(
            qrCodeDescription: strings[qrCodeDescriptionKey] ?? "",
            closeButtonTitle: strings[closeButtonTitleKey] ?? ""
        )
    }
}
