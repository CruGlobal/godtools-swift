//
//  MobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentAuthTokenCache {
    
    private let keychainAccessor: MobileContentAuthTokenKeychainAccessor
    private let realmCache: RealmMobileContentAuthTokenCache
    
    init(mobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessor, realmCache: RealmMobileContentAuthTokenCache) {
        
        self.keychainAccessor = mobileContentAuthTokenKeychainAccessor
        self.realmCache = realmCache
    }
    
    func storeAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) {
        
        do {
            
            try keychainAccessor.saveMobileContentAuthToken(authTokenDataModel)
            
            _ = realmCache.storeAuthTokenData(authTokenData: authTokenDataModel)

        } catch let error {
            
            assertionFailure("Keychain store failed with error: \(error.localizedDescription)")
        }
    }
    
    func getAuthTokenData() -> MobileContentAuthTokenDataModel? {
        
        guard let userId = getUserId(), let authToken = getAuthToken(for: userId) else {
            return nil
        }
        
        let authTokenData: RealmMobileContentAuthToken? = realmCache.getAuthTokenData(userId: userId)
                
        return MobileContentAuthTokenDataModel(
            expirationDate: authTokenData?.expirationDate,
            userId: userId,
            token: authToken,
            appleRefreshToken: getAppleRefreshToken(for: userId)
        )
    }
    
    func getAuthToken(for userId: String) -> String? {
        
        return keychainAccessor.getMobileContentAuthToken(userId: userId)
    }
    
    func getUserId() -> String? {
        
        return keychainAccessor.getMobileContentUserId()
    }
    
    func getAppleRefreshToken(for userId: String) -> String? {
        
        return keychainAccessor.getAppleRefreshToken(userId: userId)
    }
    
    func deleteAuthToken(for userId: String) {
        
        keychainAccessor.deleteMobileContentAuthTokenAndUserId(userId: userId)
        
        _ = realmCache.deleteAuthTokenData(userId: userId)
    }
}
