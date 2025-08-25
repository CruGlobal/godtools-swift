//
//  AppConfigInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

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
    func getRealmDatabase() -> RealmDatabase
    func getTractRemoteShareConnectionUrl() -> String
}
