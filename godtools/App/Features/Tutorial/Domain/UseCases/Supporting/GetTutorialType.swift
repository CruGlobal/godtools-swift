//
//  GetTutorialType.swift
//  godtools
//
//  Created by Levi Eggert on 5/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetTutorialType {
    
    init() {
        
    }
    
    func getType(appLanguage: AppLanguageDomainModel) -> TutorialTypeDomainModel {
     
        if getFullTutorialLanguages().contains(appLanguage) {
            return .full
        }
        else if getPartialTutorialLanguages().contains(appLanguage) {
            return .partial
        }
        
        return .noTutorial
    }
    
    private func getFullTutorialLanguages() -> [AppLanguageDomainModel] {
        
        return [
            LanguageCodeDomainModel.afrikaans.rawValue,
            LanguageCodeDomainModel.english.rawValue,
            LanguageCodeDomainModel.spanish.rawValue,
            LanguageCodeDomainModel.indonesian.rawValue,
            LanguageCodeDomainModel.latvian.rawValue,
            LanguageCodeDomainModel.vietnamese.rawValue
        ]
    }
    
    private func getPartialTutorialLanguages() -> [AppLanguageDomainModel] {
        
        return [
            LanguageCodeDomainModel.amharic.rawValue,
            LanguageCodeDomainModel.arabic.rawValue,
            LanguageCodeDomainModel.bangla.rawValue,
            LanguageCodeDomainModel.chineseSimplified.rawValue,
            LanguageCodeDomainModel.chineseTraditional.rawValue,
            LanguageCodeDomainModel.french.rawValue,
            LanguageCodeDomainModel.german.rawValue,
            LanguageCodeDomainModel.hausa.rawValue,
            LanguageCodeDomainModel.hindi.rawValue,
            LanguageCodeDomainModel.japanese.rawValue,
            LanguageCodeDomainModel.korean.rawValue,
            LanguageCodeDomainModel.nepali.rawValue,
            LanguageCodeDomainModel.portuguese.rawValue,
            LanguageCodeDomainModel.romanian.rawValue,
            LanguageCodeDomainModel.russian.rawValue,
            LanguageCodeDomainModel.swahili.rawValue,
            LanguageCodeDomainModel.oromo.rawValue,
            LanguageCodeDomainModel.urdu.rawValue
        ]
    }
}
