//
//  GetToolScreenShareTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
        
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> ToolScreenShareTutorialStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = ToolScreenShareTutorialStringsDomainModel(
            generateQRCodeActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.screenShareTutorialGenerateQRCodeButtonTitle.key),
            nextTutorialPageActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.tutorialContinueButtonTitleContinue.key),
            shareLinkActionTitle: await localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.shareLink.key)
        )
        
        return strings
    }
}
