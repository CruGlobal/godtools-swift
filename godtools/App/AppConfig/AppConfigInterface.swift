//
//  AppConfigInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication
import RepositorySync

protocol AppConfigInterface: Sendable {
    
    var analyticsEnabled: Bool { get }
    var dynalinkClientApiKey: String? { get }
    var firebaseEnabled: Bool { get }
    var isOptInNotificationModalEnabled: Bool { get }
    var urlRequestsEnabled: Bool { get }
    var shouldSyncInitialLanguages: Bool { get }
    var shouldSyncInitialResources: Bool { get }
    
    func getAppleAppId() -> String
    func getFacebookConfiguration() -> FacebookConfiguration?
    func getFirebaseGoogleServiceFileName() -> String
    func getGoogleAuthenticationConfiguration() -> GoogleAuthenticationConfiguration?
    func getMobileContentApiBaseUrl() -> String
    func getMobileContentCDNBaseUrl() -> String
    func getRealmDatabase() throws -> RealmDatabase
    @available(iOS 17.4, *)
    func getSwiftDatabase() throws -> SwiftDatabase?
    func getTractRemoteShareConnectionUrl() -> String
    func getUserDefaultsCache() -> UserDefaultsCacheInterface
}
