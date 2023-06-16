//
//  MobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class MobileContentAuthTokenCache {
    
    typealias UserId = String
    
    private static let sharedHashableAuthTokenSubject: HashableCurrentValueSubject<UserId, MobileContentAuthTokenDataModel, Never> = HashableCurrentValueSubject()
    private static let sharedAuthUserId: UserId = "shared_auth_user_id"
    
    private let keychainAccessor: MobileContentAuthTokenKeychainAccessor
    private let realmCache: RealmMobileContentAuthTokenCache
    
    init(mobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessor, realmCache: RealmMobileContentAuthTokenCache) {
        
        self.keychainAccessor = mobileContentAuthTokenKeychainAccessor
        self.realmCache = realmCache
        
        updateHashableAuthTokenSubject(authToken: getAuthTokenData())
    }
    
    func storeAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) {
        
        do {
            
            try keychainAccessor.saveMobileContentAuthToken(authTokenDataModel)
            
            _ = realmCache.storeAuthTokenData(authTokenData: authTokenDataModel)
            
            updateHashableAuthTokenSubject(authToken: authTokenDataModel)

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
        
        updateHashableAuthTokenSubject(authToken: nil)
    }
}

// MARK: - AuthToken CurrentValueSubject

extension MobileContentAuthTokenCache {
    
    func getAuthTokenChangedPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel?, Never> {
        
        return MobileContentAuthTokenCache.sharedHashableAuthTokenSubject.getValueChangedPublisher(hash: MobileContentAuthTokenCache.sharedAuthUserId)
            .eraseToAnyPublisher()
    }
    
    func updateHashableAuthTokenSubject(authToken: MobileContentAuthTokenDataModel?) {
        
        MobileContentAuthTokenCache.sharedHashableAuthTokenSubject.storeValue(
            hash: MobileContentAuthTokenCache.sharedAuthUserId,
            value: authToken
        )
    }
}
