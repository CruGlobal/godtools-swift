//
//  GetAppLanguageNameRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguageNameRepository: GetAppLanguageNameRepositoryInterface {
    
    private let localeLanguageName: LocaleLanguageName
    
    init(localeLanguageName: LocaleLanguageName) {
        
        self.localeLanguageName = localeLanguageName
    }
    
    func getLanguageNamePublisher(appLanguageCode: AppLanguageCodeDomainModel, translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> {
        
        let languageName: String = localeLanguageName.getDisplayName(forLanguageCode: appLanguageCode, translatedInLanguageCode: translateInLanguage) ?? ""
        
        let appLanguageName = AppLanguageNameDomainModel(value: languageName)
        
        return Just(appLanguageName)
            .eraseToAnyPublisher()
    }
}
