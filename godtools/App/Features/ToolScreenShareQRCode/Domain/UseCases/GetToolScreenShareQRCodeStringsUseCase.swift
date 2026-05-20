//
//  GetToolScreenShareQRCodeStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareQRCodeStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolScreenShareQRCodeStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ToolScreenShareQRCodeStringsDomainModel(
            qrCodeDescription: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.description"),
            closeButtonTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.closeButtonTitle")
        )
        
        return strings
    }
}
