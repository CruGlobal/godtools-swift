//
//  GetReviewShareShareableStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetReviewShareShareableStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ReviewShareShareableStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let strings = ReviewShareShareableStringsDomainModel(
            shareActionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "toolSettings.shareImagePreview.shareImageButton.title")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
