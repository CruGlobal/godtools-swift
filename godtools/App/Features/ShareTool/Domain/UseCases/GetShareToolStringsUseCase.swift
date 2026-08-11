//
//  GetShareToolStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetShareToolStringsUseCase {
    
    private let getShareToolUrl: GetShareToolUrl
    private let localizationServices: LocalizationServicesInterface
        
    init(getShareToolUrl: GetShareToolUrl, localizationServices: LocalizationServicesInterface) {
        
        self.getShareToolUrl = getShareToolUrl
        self.localizationServices = localizationServices
    }
    
    func execute(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel) async -> ShareToolStringsDomainModel {
        
        let qrCodeActionTitle: String = await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.toolScreenShareQrCodeTitle.key)
        
        let shareMessage = await getShareMessage(
            toolId: toolId,
            toolLanguageId: toolLanguageId,
            pageNumber: pageNumber,
            appLanguage: appLanguage
        )
        
        let strings = ShareToolStringsDomainModel(
            shareMessage: shareMessage,
            qrCodeActionTitle: qrCodeActionTitle
        )
        
        return strings
    }
    
    private func getShareMessage(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel) async -> String {
        
        let toolUrl: String? = getShareToolUrl.getUrl(toolId: toolId, toolLanguageId: toolLanguageId, pageNumber: pageNumber)
        
        let localizedShareToolMessage: String = await localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.tractShareMessage.key)
        
        guard let toolUrl = toolUrl else {
            
            return localizedShareToolMessage
        }
        
        let shareMessageWithToolUrl = String.localizedStringWithFormat(localizedShareToolMessage, toolUrl)
        
        return shareMessageWithToolUrl
    }
}
