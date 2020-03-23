//
//  IsNewUserCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol IsNewUserCacheType {
    
    var isNewUser: Bool { get }
    
    func cacheIsNewUser(isNewUser: Bool)
}
