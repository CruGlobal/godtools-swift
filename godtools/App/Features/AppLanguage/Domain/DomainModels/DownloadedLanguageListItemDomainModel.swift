//
//  DownloadedLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageListItemDomainModel: Sendable {
    
    let languageId: String
    let languageCode: BCP47LanguageIdentifier
    let languageNamePair: TranslatedLanguageNamePairDomainModel
}

extension DownloadedLanguageListItemDomainModel: Identifiable {
    
    var id: String {
        return languageId
    }
}
