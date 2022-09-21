//
//  ResourceModel+LanguageSupportable.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension ResourceModel: LanguageSupportable {
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return languageIds.contains(languageId)
        }
        return false
    }
}
