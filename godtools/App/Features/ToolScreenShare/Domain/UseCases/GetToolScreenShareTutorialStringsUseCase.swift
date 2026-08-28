//
//  GetToolScreenShareTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareTutorialStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
        
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> ToolScreenShareTutorialStringsDomainModel {

        let generateQRCodeActionTitleKey: String = LocalizableStringKeys.screenShareTutorialGenerateQRCodeButtonTitle.key
        let nextTutorialPageActionTitleKey: String = LocalizableStringKeys.tutorialContinueButtonTitleContinue.key
        let shareLinkActionTitleKey: String = LocalizableStringKeys.shareLink.key
        let skipActionTitleKey: String = LocalizableStringKeys.navigationBarNavigationItemSkip.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                generateQRCodeActionTitleKey,
                nextTutorialPageActionTitleKey,
                shareLinkActionTitleKey,
                skipActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return ToolScreenShareTutorialStringsDomainModel(
            generateQRCodeActionTitle: strings[generateQRCodeActionTitleKey] ?? "",
            nextTutorialPageActionTitle: strings[nextTutorialPageActionTitleKey] ?? "",
            shareLinkActionTitle: strings[shareLinkActionTitleKey] ?? "",
            skipActionTitle: strings[skipActionTitleKey] ?? ""
        )
    }
}
