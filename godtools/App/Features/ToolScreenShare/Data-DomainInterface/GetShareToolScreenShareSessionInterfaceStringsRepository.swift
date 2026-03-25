//
//  GetShareToolScreenShareSessionInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetShareToolScreenShareSessionInterfaceStringsRepository: GetShareToolScreenShareSessionInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolScreenShareSessionInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let shareMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_remote_link_message")
        let qrCodeActionTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.title")
        
        let interfaceStrings = ShareToolScreenShareSessionInterfaceStringsDomainModel(
            shareMessage: shareMessage,
            qrCodeActionTitle: qrCodeActionTitle
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
