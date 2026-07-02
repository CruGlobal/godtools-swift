//
//  MobileContentAuthTokenDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDataModel: Sendable {
    
    let appleRefreshToken: String?
    let expirationDate: Date?
    let id: String
    let token: String
    let userId: String
    
    var isExpired: Bool {
        
        guard let expirationDate = self.expirationDate else {
            return true
        }
                
        let secondsTilExpiration: TimeInterval = Date().timeIntervalSince(expirationDate)
        let isExpired: Bool = secondsTilExpiration >= 0
        
        return isExpired
    }
}
