//
//  CachedAuthToken.swift
//  godtools
//
//  Created by Levi Eggert on 2/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct CachedAuthToken: Sendable {
    
    let appleRefreshToken: String?
    let expirationDate: Date?
    let id: String
    let token: String
    let userId: String
    
    init(appleRefreshToken: String?, expirationDate: Date?, token: String, userId: String) {
        
        self.appleRefreshToken = appleRefreshToken
        self.expirationDate = expirationDate
        self.id = userId
        self.token = token
        self.userId = userId
    }
}
