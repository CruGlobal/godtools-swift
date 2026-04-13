//
//  GetToolScreenShareTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolScreenShareTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
        
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolScreenShareTutorialStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = ToolScreenShareTutorialStringsDomainModel(
            generateQRCodeActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "screenShareTutorial.generateQRCodeButton.title"),
            nextTutorialPageActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "tutorial.continueButton.title.continue"),
            shareLinkActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "share_link")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
