//
//  GetDownloadableLanguagesStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDownloadableLanguagesStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadableLanguagesStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let interfaceStrings = DownloadableLanguagesStringsDomainModel(
            navTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: AppLanguageStringKeys.DownloadableLanguages.navTitle.rawValue)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
