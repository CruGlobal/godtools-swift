//
//  IsNewUserService.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class IsNewUserService {
    
    let isNewUserCache: IsNewUserCacheType
    
    required init(determineNewUser: DetermineIfNewUserType, isNewUserCache: IsNewUserCacheType) {
        
        self.isNewUserCache = isNewUserCache
        
        isNewUserCache.cacheIsNewUser(isNewUser: determineNewUser.isNewUser)
    }
}
