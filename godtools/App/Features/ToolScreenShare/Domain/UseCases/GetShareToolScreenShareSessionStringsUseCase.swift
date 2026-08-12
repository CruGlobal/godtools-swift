//
//  GetShareToolScreenShareSessionStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetShareToolScreenShareSessionStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> ShareToolScreenShareSessionStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let shareMessage: String = await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolRemoteLinkMessage.key)
        let qrCodeActionTitle: String = await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolScreenShareQrCodeTitle.key)
        
        let strings = ShareToolScreenShareSessionStringsDomainModel(
            shareMessage: shareMessage,
            qrCodeActionTitle: qrCodeActionTitle
        )
        
        return strings
    }
}
