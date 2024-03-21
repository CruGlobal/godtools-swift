//
//  GetReviewShareShareableInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetReviewShareShareableInterfaceStringsRepository: GetReviewShareShareableInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ReviewShareShareableInterfaceStringsDomainModel, Never> {
        
        let localeId: String = translateInLanguage
        
        let interfaceStrings = ReviewShareShareableInterfaceStringsDomainModel(
            shareActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.shareImagePreview.shareImageButton.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
