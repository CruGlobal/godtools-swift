//
//  GetShareToolScreenShareSessionStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetShareToolScreenShareSessionStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ShareToolScreenShareSessionStringsDomainModel {

        let shareMessageKey: String = LocalizableStringKeys.shareToolRemoteLinkMessage.key
        let qrCodeActionTitleKey: String = LocalizableStringKeys.toolScreenShareQrCodeTitle.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                shareMessageKey,
                qrCodeActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ShareToolScreenShareSessionStringsDomainModel(
            shareMessage: strings[shareMessageKey] ?? "",
            qrCodeActionTitle: strings[qrCodeActionTitleKey] ?? ""
        )
    }
}
