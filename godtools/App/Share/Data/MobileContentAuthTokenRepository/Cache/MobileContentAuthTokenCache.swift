//
//  MobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentAuthTokenCache {
    
    let keychainService: KeychainService
    
    init(keychainService: KeychainService) {
        
        self.keychainService = keychainService
    }
    
    func storeAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) {
        
        keychainService.saveMobileContentAuthToken(authTokenDataModel)
    }
}
