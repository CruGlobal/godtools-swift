//
//  MobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentAuthTokenCache {
    
    enum CacheKey: String {
        
        case expirationDate = "expirationDate"
        
        func getUserKey(userId: String) -> String {
            return "MobileContentAuthTokenCache.\(userId).\(rawValue)"
        }
    }
    
    private let sharedUserDefaults: SharedUserDefaultsCache
    
    let keychainAccessor: MobileContentAuthTokenKeychainAccessor
    
    init(mobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessor, sharedUserDefaults: SharedUserDefaultsCache) {
        
        self.keychainAccessor = mobileContentAuthTokenKeychainAccessor
        self.sharedUserDefaults = sharedUserDefaults
    }
    
    private func storeExpirationDate(userId: String, expirationDate: Date) {
        
        sharedUserDefaults.cache(value: expirationDate, forKey: CacheKey.expirationDate.getUserKey(userId: userId))
    }
    
    private func getExpirationDate(userId: String) -> Date? {
        
        return sharedUserDefaults.getValue(key: CacheKey.expirationDate.getUserKey(userId: userId)) as? Date
    }
    
    private func deleteExpirationDate(userId: String) {
        
        sharedUserDefaults.cache(value: nil, forKey: CacheKey.expirationDate.getUserKey(userId: userId))
    }
    
    func storeAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) {
        
        do {
            
            try keychainAccessor.saveMobileContentAuthToken(authTokenDataModel)
            
            if let expirationDate = authTokenDataModel.expirationDate {
                storeExpirationDate(userId: authTokenDataModel.userId, expirationDate: expirationDate)
            }
            
        } catch let error {
            
            assertionFailure("Keychain store failed with error: \(error.localizedDescription)")
        }
    }
    
    func getAuthTokenData() -> MobileContentAuthTokenDataModel? {
        
        guard let userId = getUserId(), let authToken = getAuthToken(for: userId) else {
            return nil
        }
            
        return MobileContentAuthTokenDataModel(
            expirationDate: getExpirationDate(userId: userId),
            userId: userId,
            token: authToken
        )
    }
    
    func getAuthToken(for userId: String) -> String? {
        
        return keychainAccessor.getMobileContentAuthToken(userId: userId)
    }
    
    func getUserId() -> String? {
        
        return keychainAccessor.getMobileContentUserId()
    }
    
    func deleteAuthToken(for userId: String) {
        
        keychainAccessor.deleteMobileContentAuthTokenAndUserId(userId: userId)
        
        deleteExpirationDate(userId: userId)
    }
}
