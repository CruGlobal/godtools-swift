//
//  MobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentAuthTokenCache {
    
    let keychainAccessor: MobileContentAuthTokenKeychainAccessor
    
    init(mobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessor) {
        
        self.keychainAccessor = mobileContentAuthTokenKeychainAccessor
    }
    
    func storeAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) {
        
        do {
            
            try keychainAccessor.saveMobileContentAuthToken(authTokenDataModel)
            
        } catch let error {
            
            assertionFailure("Keychain store failed with error: \(error.localizedDescription)")
        }
    }
    
    func getAuthToken(for userId: String) -> String? {
        
        return keychainAccessor.getMobileContentAuthToken(userId: userId)
    }
    
    func getUserId() -> String? {
        
        return keychainAccessor.getMobileContentUserId()
    }
}
