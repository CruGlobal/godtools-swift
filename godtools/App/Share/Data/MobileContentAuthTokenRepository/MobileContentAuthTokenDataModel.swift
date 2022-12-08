//
//  MobileContentAuthTokenDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct MobileContentAuthTokenDataModel {
    
    let userId: String
    let token: String
}

extension MobileContentAuthTokenDataModel {
    
    init(decodable: MobileContentAuthTokenDecodable) {
        
        self.userId = decodable.userId
        self.token = decodable.token
    }
}
