//
//  GetToolScreenShareQRCodeInterfaceStringsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import LocalizationServices

class GetToolScreenShareQRCodeInterfaceStringsRepository: GetToolScreenShareQRCodeInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolScreenShareQRCodeInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = ToolScreenShareQRCodeInterfaceStringsDomainModel(
            qrCodeDescription: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.description"),
            closeButtonTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.closeButtonTitle")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
