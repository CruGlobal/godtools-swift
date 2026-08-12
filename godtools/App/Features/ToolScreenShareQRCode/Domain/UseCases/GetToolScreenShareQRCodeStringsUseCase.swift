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
    
    func execute(appLanguage: AppLanguageDomainModel) async -> ToolScreenShareQRCodeStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ToolScreenShareQRCodeStringsDomainModel(
            qrCodeDescription: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolScreenShareQrCodeDescription.key),
            closeButtonTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolScreenShareQrCodeCloseButtonTitle.key)
        )
        
        return strings
    }
}
