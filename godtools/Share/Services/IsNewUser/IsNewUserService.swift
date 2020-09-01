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
    let isNewUserCache: IsNewUserCacheType
    
    required init(isNewUserCache: IsNewUserCacheType, determineNewUser: DetermineIfNewUserType) {
                
        self.determineNewUser = determineNewUser
        self.isNewUserCache = isNewUserCache
        
        isNewUserCache.cacheIsNewUser(isNewUser: determineNewUser.isNewUser)
    }
}
