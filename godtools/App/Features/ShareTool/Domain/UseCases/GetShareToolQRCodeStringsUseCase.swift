//
//  GetShareToolQRCodeStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetShareToolQRCodeStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ShareToolQRCodeStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ShareToolQRCodeStringsDomainModel(
            message: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolQrCodeMessage.key),
            closeActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolScreenShareQrCodeCloseButtonTitle.key)
        )
        
        return strings
    }
}
