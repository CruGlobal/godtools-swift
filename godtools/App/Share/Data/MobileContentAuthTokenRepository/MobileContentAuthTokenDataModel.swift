//
//  MobileContentAuthTokenDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDataModel {
    
    let expirationDate: Date?
    let userId: String
    let token: String
    let appleRefreshToken: String?
    
    var isExpired: Bool {
        
        guard let expirationDate = self.expirationDate else {
            return true
        }
                
        let secondsTilExpiration: TimeInterval = Date().timeIntervalSince(expirationDate)
        let isExpired: Bool = secondsTilExpiration >= 0
        
        return isExpired
    }
}

extension MobileContentAuthTokenDataModel {
    
    init(decodable: MobileContentAuthTokenDecodable) {
        
        self.expirationDate = decodable.expirationDate
        self.userId = decodable.userId
        self.token = decodable.token
        self.appleRefreshToken = decodable.appleRefreshToken
    }
}
