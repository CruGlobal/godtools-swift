//
//  GetLanguageElseAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

class GetLanguageElseAppLanguage {
    
    private let languagesRepository: LanguagesRepository
    
    init(languagesRepository: LanguagesRepository) {
       
        self.languagesRepository = languagesRepository
    }
    
    func getLanguage(languageId: String?, appLanguage: AppLanguageDomainModel) -> LanguageDataModel? {
        
        return getLanguage(id: languageId) ?? languagesRepository.cache.getCachedLanguage(code: appLanguage)
    }
    
    func getLanguageCode(languageId: String?, appLanguage: AppLanguageDomainModel) -> String {
        
        return getLanguage(id: languageId)?.code ?? appLanguage
    }
    
    private func getLanguage(id: String?) -> LanguageDataModel? {
        
        if let languageId = id,
           let language = languagesRepository.persistence.getDataModelNonThrowing(id: languageId) {
            
            return language
        }
        
        return nil
    }
}
