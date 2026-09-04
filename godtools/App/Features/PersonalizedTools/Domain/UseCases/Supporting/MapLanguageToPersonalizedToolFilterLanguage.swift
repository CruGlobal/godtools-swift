//
//  MapLanguageToPersonalizedToolFilterLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class MapLanguageToPersonalizedToolFilterLanguage: Sendable {
    
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func map(
        language: LanguageDataModel,
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> PersonalizedToolFilterLanguageDomainModel {
        
        let languageNamePair: TranslatedLanguageNamePairDomainModel = getTranslatedLanguageName.getLanguageNamePair(
            language: language,
            appLanguage: translatedInAppLanguage
        )
        
        return PersonalizedToolFilterLanguageDomainModel(
            id: language.id,
            languageId: language.id,
            languageNamePair: languageNamePair
        )
    }
}
