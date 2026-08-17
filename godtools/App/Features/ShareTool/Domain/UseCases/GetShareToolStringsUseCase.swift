//
//  GetShareToolStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetShareToolStringsUseCase: Sendable {
    
    private let getShareToolUrl: GetShareToolUrl
    private let localizationServices: LocalizationServicesInterface
        
    init(getShareToolUrl: GetShareToolUrl, localizationServices: LocalizationServicesInterface) {
        
        self.getShareToolUrl = getShareToolUrl
        self.localizationServices = localizationServices
    }
    
    func execute(toolId: String, toolLanguageId: String, pageNumber: Int, appLanguage: AppLanguageDomainModel) -> ShareToolStringsDomainModel {

        let qrCodeActionTitleKey: String = LocalizableStringKeys.toolScreenShareQrCodeTitle.key
        let shareMessageKey: String = LocalizableStringKeys.tractShareMessage.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                qrCodeActionTitleKey,
                shareMessageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let shareMessage = getShareMessage(
            toolId: toolId,
            toolLanguageId: toolLanguageId,
            pageNumber: pageNumber,
            localizedShareToolMessage: strings[shareMessageKey] ?? ""
        )

        return ShareToolStringsDomainModel(
            shareMessage: shareMessage,
            qrCodeActionTitle: strings[qrCodeActionTitleKey] ?? ""
        )
    }

    private func getShareMessage(toolId: String, toolLanguageId: String, pageNumber: Int, localizedShareToolMessage: String) -> String {

        let toolUrl: String? = getShareToolUrl.getUrl(toolId: toolId, toolLanguageId: toolLanguageId, pageNumber: pageNumber)

        guard let toolUrl = toolUrl else {
            
            return localizedShareToolMessage
        }
        
        let shareMessageWithToolUrl = String.localizedStringWithFormat(localizedShareToolMessage, toolUrl)
        
        return shareMessageWithToolUrl
    }
}
