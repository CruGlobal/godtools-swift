//
//  DownloadedLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageListItemDomainModel {
    
    let languageId: String
    let languageCode: BCP47LanguageIdentifier
    let languageNameInOwnLanguage: String
    let languageNameInAppLanguage: String
}

extension DownloadedLanguageListItemDomainModel: Identifiable {
    
    var id: String {
        return languageId
    }
}
