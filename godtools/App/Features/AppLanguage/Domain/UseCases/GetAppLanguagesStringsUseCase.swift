//
//  GetAppLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetAppLanguagesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguagesStringsDomainModel, Never> {
                
        let strings = AppLanguagesStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: AppLanguageStringKeys.AppLanguages.navTitle.rawValue)
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
