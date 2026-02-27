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

class MobileContentAuthTokenCache {
    
    typealias UserId = String
    
    private static let sharedHashableAuthTokenSubject: HashableCurrentValueSubject<UserId, MobileContentAuthTokenDataModel, Never> = HashableCurrentValueSubject()
    private static let sharedAuthUserId: UserId = "shared_auth_user_id"
    
    private let keychainAccessor: MobileContentAuthTokenKeychainAccessorInterface
    private let persistence: any Persistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable>
    
    init(mobileContentAuthTokenKeychainAccessor: MobileContentAuthTokenKeychainAccessorInterface, persistence: any Persistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable>) {
        
        self.keychainAccessor = mobileContentAuthTokenKeychainAccessor
        self.persistence = persistence
        
        do {
            
            let cachedAuthToken: CachedAuthToken? = try getCachedAuthToken()
            let dataModel: MobileContentAuthTokenDataModel?
            
            if let cachedAuthToken = cachedAuthToken {
                dataModel = MobileContentAuthTokenDataModel(authToken: cachedAuthToken)
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
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable, SwiftMobileContentAuthToken>? {
        return persistence as? SwiftRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable, SwiftMobileContentAuthToken>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable, RealmMobileContentAuthToken>? {
        return persistence as? RealmRepositorySyncPersistence<MobileContentAuthTokenDataModel, MobileContentAuthTokenDecodable, RealmMobileContentAuthToken>
    }
}

extension MobileContentAuthTokenCache {
    
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenDecodable) async throws {
        
        try keychainAccessor.saveMobileContentAuthToken(authTokenCodable: authTokenCodable)
        
        _ = try await persistence.writeObjectsAsync(
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
        
        let dataModel = MobileContentAuthTokenDataModel(authToken: cachedAuthToken)
                
        updateHashableAuthTokenSubject(authToken: dataModel)
    }
    
    func getCachedAuthToken() throws -> CachedAuthToken? {
        
        guard let userId = getUserId(), let authToken = getAuthToken(for: userId) else {
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
    
    func getAuthToken(for userId: String) -> String? {
        
        return keychainAccessor.getMobileContentAuthToken(userId: userId)
    }
    
    func getUserId() -> String? {
        
        return keychainAccessor.getMobileContentUserId()
    }
    
    func deleteAuthToken(for userId: String) throws {
        
        keychainAccessor.deleteMobileContentAuthTokenAndUserId(userId: userId)
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let object: SwiftMobileContentAuthToken? = try database.read.object(context: context, id: userId)
            
            guard let object = object else {
                return
            }
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(
                    deleteObjects: [object],
                    insertObjects: nil
                )
            )
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let object: RealmMobileContentAuthToken? = database.read.object(realm: realm, id: userId)
            
            guard let object = object else {
                return
            }
            
            try database.write.realm(realm: realm, writeClosure: { realm in
                return WriteRealmObjects(deleteObjects: [object], addObjects: nil)
            }, updatePolicy: .modified)
        }
        
        updateHashableAuthTokenSubject(authToken: nil)
    }
}

// MARK: - AuthToken CurrentValueSubject

extension MobileContentAuthTokenCache {
    
    func getAuthTokenChangedPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel?, Never> {
        
        return MobileContentAuthTokenCache
            .sharedHashableAuthTokenSubject
            .getValueChangedPublisher(
                hash: MobileContentAuthTokenCache.sharedAuthUserId
            )
            .eraseToAnyPublisher()
    }
    
    func updateHashableAuthTokenSubject(authToken: MobileContentAuthTokenDataModel?) {
        
        MobileContentAuthTokenCache.sharedHashableAuthTokenSubject.storeValue(
            hash: MobileContentAuthTokenCache.sharedAuthUserId,
            value: authToken
        )
    }
}
