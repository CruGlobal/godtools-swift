//
//  MapLanguageToPersonalizedLessonFilterLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class MapLanguageToPersonalizedLessonFilterLanguage: Sendable {
    
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func map(
        language: LanguageDataModel,
        translatedInAppLanguage: AppLanguageDomainModel
    ) -> PersonalizedLessonFilterLanguageDomainModel {
        
        let languageNamePair: TranslatedLanguageNamePairDomainModel = getTranslatedLanguageName.getLanguageNamePair(
            language: language,
            appLanguage: translatedInAppLanguage
        )
        
        return PersonalizedLessonFilterLanguageDomainModel(
            id: language.id,
            languageId: language.id,
            languageNamePair: languageNamePair
        )
    }
}
