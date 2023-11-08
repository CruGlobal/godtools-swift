//
//  GetToolScreenShareTutorialInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolScreenShareTutorialInterfaceStringsRepository: GetToolScreenShareTutorialInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
        
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<ToolScreenShareInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = ToolScreenShareInterfaceStringsDomainModel(
            nextTutorialPageActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "tutorial.continueButton.title.continue"),
            shareLinkActionTitle: localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeId, key: "share_link")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
