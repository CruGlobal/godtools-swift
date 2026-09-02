//
//  AuthTokenCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol AuthTokenCacheInterface: Sendable {
    
    func getUserId() -> String?
    func getCachedAuthToken() throws -> CachedAuthToken?
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenCodable) async throws
    func deleteAuthToken(userId: String) async throws
    func getAuthTokenStream() async -> AsyncStream<MobileContentAuthTokenDataModel?>
}
