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

protocol AppConfigInterface {
    
    var analyticsEnabled: Bool { get }
    var buildConfig: AppBuildConfiguration { get }
    var environment: AppEnvironment { get }
    var firebaseEnabled: Bool { get }
    var isDebug: Bool { get }
    var urlRequestsEnabled: Bool { get }
    
    func getAppleAppId() -> String
    func getFacebookConfiguration() -> FacebookConfiguration?
    func getFirebaseGoogleServiceFileName() -> String
    func getGoogleAuthenticationConfiguration() -> GoogleAuthenticationConfiguration?
    func getMobileContentApiBaseUrl() -> String
    func getLegacyRealmDatabase() -> LegacyRealmDatabase
    func getRealmDatabase() -> RealmDatabase
    @available(iOS 17.4, *)
    func getSwiftDatabase() throws -> SwiftDatabase?
    func getTractRemoteShareConnectionUrl() -> String
}
