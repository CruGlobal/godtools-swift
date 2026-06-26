//
//  GetShareToolScreenShareSessionStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetShareToolScreenShareSessionStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolScreenShareSessionStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let shareMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareToolRemoteLinkMessage.key)
        let qrCodeActionTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.toolScreenShareQrCodeTitle.key)
        
        let strings = ShareToolScreenShareSessionStringsDomainModel(
            shareMessage: shareMessage,
            qrCodeActionTitle: qrCodeActionTitle
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
