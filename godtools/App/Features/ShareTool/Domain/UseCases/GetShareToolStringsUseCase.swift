//
//  GetShareToolStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetShareToolStringsUseCase {
    
    private let getShareToolUrl: GetShareToolUrl
    private let localizationServices: LocalizationServicesInterface
        
    init(getShareToolUrl: GetShareToolUrl, localizationServices: LocalizationServicesInterface) {
        
        self.getShareToolUrl = getShareToolUrl
        self.localizationServices = localizationServices
    }
    
    func execute(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel) -> AnyPublisher<ShareToolStringsDomainModel, Never> {
        
        let qrCodeActionTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "toolScreenShare.qrCode.title")
        
        let strings = ShareToolStringsDomainModel(
            shareMessage: getShareMessage(
                toolId: toolId,
                toolLanguageId: toolLanguageId,
                pageNumber: pageNumber,
                appLanguage: appLanguage
            ),
            qrCodeActionTitle: qrCodeActionTitle
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
    
    private func getShareMessage(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel) -> String {
        
        let toolUrl: String? = getShareToolUrl.getUrl(toolId: toolId, toolLanguageId: toolLanguageId, pageNumber: pageNumber)
        
        let localizedShareToolMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "tract_share_message")
        
        guard let toolUrl = toolUrl else {
            
            return localizedShareToolMessage
        }
        
        let shareMessageWithToolUrl = String.localizedStringWithFormat(localizedShareToolMessage, toolUrl)
        
        return shareMessageWithToolUrl
    }
}
