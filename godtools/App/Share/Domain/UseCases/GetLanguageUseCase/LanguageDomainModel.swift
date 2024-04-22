//
//  LanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // Deprecating and I think instead we can pass language dataModel ids around. ~Levi
struct LanguageDomainModel {

    let analyticsContentLanguage: String
    let dataModelId: String
    let direction: LanguageDirectionDomainModel
    let localeIdentifier: BCP47LanguageIdentifier
    @available(*, deprecated) // Deprecating translatedName as language name translations should now come through TranslatedLanguageNameRepository. ~Levi
    let translatedName: String
}

extension LanguageDomainModel: Equatable {}

extension LanguageDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
