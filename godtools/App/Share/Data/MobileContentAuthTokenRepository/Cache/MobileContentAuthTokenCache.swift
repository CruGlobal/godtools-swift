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
        
        do {
            
            try keychainService.saveMobileContentAuthToken(authTokenDataModel)
            
        } catch let error {
            
            assertionFailure("Keychain store failed with error: \(error.localizedDescription)")
        }
    }
    
    func getAuthToken(for userId: Int) -> String? {
        
        return keychainService.getMobileContentAuthToken(userId: userId)
    }
}
