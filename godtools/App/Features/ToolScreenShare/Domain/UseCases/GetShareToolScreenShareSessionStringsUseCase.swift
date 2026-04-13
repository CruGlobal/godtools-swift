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
        
        let shareMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "share_tool_remote_link_message")
        let qrCodeActionTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolScreenShare.qrCode.title")
        
        let strings = ShareToolScreenShareSessionStringsDomainModel(
            shareMessage: shareMessage,
            qrCodeActionTitle: qrCodeActionTitle
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
