//
//  MobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync
import SwiftData
import RealmSwift

final class MobileContentAuthTokenCache: AuthTokenCacheInterface {
    
    typealias UserId = String
    
    private static let sharedHashableAuthTokenSubject: HashableCurrentValueSubject<UserId, MobileContentAuthTokenDataModel, Never> = HashableCurrentValueSubject()
    private static let sharedAuthUserId: UserId = "shared_auth_user_id"
    
    private let keychainAccessor: MobileContentAuthTokenKeychainAccessorInterface
    private let persistence: any Persistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenCodable>
    
    init(
        mobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessorInterface,
        persistence: any Persistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenCodable>
    ) {
        
        self.keychainAccessor = mobileContentAuthTokenKeychainAccessor
        self.persistence = persistence
        
        do {
            
            let cachedAuthToken: CachedAuthToken? = try getCachedAuthToken()
            let dataModel: MobileContentAuthTokenDataModel?
            
            if let cachedAuthToken = cachedAuthToken {
                dataModel = cachedAuthToken.toModel()
            }
            else {
                dataModel = nil
            }
            
            updateHashableAuthTokenSubject(authToken: dataModel)
        }
        catch let error {
            
            assertionFailure("\n MobileContentAuthTokenCache failed to get cached auth token with error: \(error)")
        }
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenCodable, SwiftMobileContentAuthToken>? {
        return persistence as? SwiftRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenCodable, SwiftMobileContentAuthToken>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenCodable, RealmMobileContentAuthToken>? {
        return persistence as? RealmRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenCodable, RealmMobileContentAuthToken>
    }
    
    func getAuthTokenChangedPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel?, Never> {
        
        return MobileContentAuthTokenCache
            .sharedHashableAuthTokenSubject
            .getValueChangedPublisher(
                hash: MobileContentAuthTokenCache.sharedAuthUserId
            )
            .eraseToAnyPublisher()
    }
    
    private func updateHashableAuthTokenSubject(authToken: MobileContentAuthTokenDataModel?) {
        
        MobileContentAuthTokenCache.sharedHashableAuthTokenSubject.storeValue(
            hash: MobileContentAuthTokenCache.sharedAuthUserId,
            value: authToken
        )
    }
    
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenCodable) async throws {
        
        try keychainAccessor.saveMobileContentAuthToken(authTokenCodable: authTokenCodable)
        
        _ = try await persistence.writeObjects(
            externalObjects: [authTokenCodable],
            writeOption: nil,
            getOption: nil
        )
        
        let cachedAuthToken = CachedAuthToken(
            appleRefreshToken: authTokenCodable.appleRefreshToken,
            expirationDate: authTokenCodable.expirationDate,
            token: authTokenCodable.token,
            userId: authTokenCodable.userId
        )
        
        let dataModel = cachedAuthToken.toModel()
                
        updateHashableAuthTokenSubject(authToken: dataModel)
    }
    
    func getCachedAuthToken() throws -> CachedAuthToken? {
        
        guard let userId = getUserId(), let authToken = getMobileContentAuthToken(userId: userId) else {
            return nil
        }
        
        let persistedTokenData: MobileContentAuthTokenDataModel? = try persistence.getDataModel(id: userId)
        
        return CachedAuthToken(
            appleRefreshToken: keychainAccessor.getAppleRefreshToken(userId: userId),
            expirationDate: persistedTokenData?.expirationDate,
            token: authToken,
            userId: userId
        )
    }
    
    private func getMobileContentAuthToken(userId: String) -> String? {
        
        return keychainAccessor.getMobileContentAuthToken(userId: userId)
    }
    
    func getUserId() -> String? {
        
        return keychainAccessor.getMobileContentUserId()
    }
    
    func deleteAuthToken(userId: String) async throws {
        
        keychainAccessor.deleteMobileContentAuthTokenAndUserId(userId: userId)
        
        _ = try await persistence.deleteObjectsByIds(ids: [userId], getOption: nil)
        
        updateHashableAuthTokenSubject(authToken: nil)
    }
}
