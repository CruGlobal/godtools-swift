//
//  GetShareToolQRCodeStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetShareToolQRCodeStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolQRCodeStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = ShareToolQRCodeStringsDomainModel(
            message: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "shareToolQrCode.message"),
            closeActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.closeButtonTitle")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
