//
//  DetermineNewUserIfPrimaryLanguageSet.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DetermineNewUserIfPrimaryLanguageSet: DetermineIfNewUserType {
    
    let isNewUser: Bool
    
    required init(languageSettingsCache: LanguageSettingsCacheType) {
        self.isNewUser = languageSettingsCache.primaryLanguageId.value == nil
    }
}
