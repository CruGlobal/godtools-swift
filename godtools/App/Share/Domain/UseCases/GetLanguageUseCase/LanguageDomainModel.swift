//
//  LanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct LanguageDomainModel {

    let analyticsContentLanguage: String
    let dataModelId: String
    let direction: LanguageDirectionDomainModel
    let localeIdentifier: String
    let translatedName: String
}

extension LanguageDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
