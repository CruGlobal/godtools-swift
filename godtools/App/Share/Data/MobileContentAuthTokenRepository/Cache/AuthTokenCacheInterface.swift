//
//  AuthTokenCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

protocol AuthTokenCacheInterface: Sendable {
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error>
    func getUserId() -> String?
    func getAuthToken() throws -> CachedAuthToken?
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenCodable) async throws
    func deleteAuthToken(userId: String) async throws
}
