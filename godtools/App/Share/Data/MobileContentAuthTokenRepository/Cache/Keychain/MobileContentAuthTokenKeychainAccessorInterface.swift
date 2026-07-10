//
//  MobileContentAuthTokenKeychainAccessorInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAuthTokenKeychainAccessorInterface {
    
    func saveMobileContentAuthToken(authTokenCodable: MobileContentAuthTokenCodable) throws
    func deleteMobileContentAuthTokenAndUserId(userId: String)
    func getMobileContentAuthToken(userId: String) -> String?
    func getMobileContentUserId() -> String?
    func getAppleRefreshToken(userId: String) -> String?
}
