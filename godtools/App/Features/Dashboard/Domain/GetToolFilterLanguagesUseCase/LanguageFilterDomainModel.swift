//
//  LanguageFilterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LanguageFilterDomainModel {
    
    let language: LanguageDomainModel?
    let translatedName: String
    let toolsAvailableText: String
}

extension LanguageFilterDomainModel {
    
    var id: String? {
        return language?.id
    }
}
