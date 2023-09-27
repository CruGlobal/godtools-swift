//
//  GetAppLanguageNameRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguageNameRepository: GetAppLanguageNameRepositoryInterface {
    
    private let localeLanguageName: LocaleLanguageName
    
    init(localeLanguageName: LocaleLanguageName) {
        
        self.localeLanguageName = localeLanguageName
    }
    
    func getLanguageName(languageCode: AppLanguageCodeDomainModel, translateInLanguageCode: AppLanguageCodeDomainModel) -> AppLanguageNameDomainModel {
        
        let languageName: String = localeLanguageName.getDisplayName(forLanguageCode: languageCode, translatedInLanguageCode: translateInLanguageCode) ?? ""
        
        return AppLanguageNameDomainModel(value: languageName)
    }
}
