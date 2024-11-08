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
    
    func getAppleAppId() -> String
    func getFacebookConfiguration() -> FacebookConfiguration
    func getFirebaseGoogleServiceFileName() -> String
    func getGoogleAuthenticationConfiguration() -> GoogleAuthenticationConfiguration
    func getMobileContentApiBaseUrl() -> String
    func getTractRemoteShareConnectionUrl() -> String
}
