//
//  ResourceDataModel+LanguageSupportable.swift
//  godtools
//
//  Created by Levi Eggert on 9/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

extension ResourceDataModel: LanguageSupportable {
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return getLanguageIds().contains(languageId)
        }
        return false
    }
}
