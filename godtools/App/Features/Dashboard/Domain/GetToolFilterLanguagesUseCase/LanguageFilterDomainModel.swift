//
//  LanguageFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LanguageFilterDomainModel {
    
    let languageName: String
    let toolsAvailableText: String
    let searchableText: String
    let language: LanguageDomainModel?
}

extension LanguageFilterDomainModel {
    
    var id: String? { language?.id }
    var translatedName: String? { language?.translatedName }
}
