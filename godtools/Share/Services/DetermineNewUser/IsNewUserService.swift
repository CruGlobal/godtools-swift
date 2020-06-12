//
//  IsNewUserService.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class IsNewUserService {
    
    let determineNewUser: DetermineIfNewUserType
    let isNewUserCache: IsNewUserCacheType = IsNewUserDefaultsCache()
    
    required init(languageManager: LanguagesManager) {
                
        determineNewUser = DetermineNewUserIfPrimaryLanguageSet(languageManager: languageManager)
        isNewUserCache.cacheIsNewUser(isNewUser: determineNewUser.isNewUser)
    }
}
