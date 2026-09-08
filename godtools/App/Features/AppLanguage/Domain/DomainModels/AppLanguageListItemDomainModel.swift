//
//  AppLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageListItemDomainModel: Sendable {
    
    let language: AppLanguageDomainModel
    let languageNamePair: TranslatedLanguageNamePairDomainModel
}

extension AppLanguageListItemDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [
            languageNamePair.nameInOwnLanguage,
            languageNamePair.nameInAppLanguage
        ]
    }
}

extension AppLanguageListItemDomainModel: Identifiable {
    var id: String {
        return language
    }
}
