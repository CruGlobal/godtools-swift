//
//  AuthTokenCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

protocol AuthTokenCacheInterface {
    
    func getUserId() -> String?
    func getCachedAuthToken() throws -> CachedAuthToken?
    func storeAuthToken(authTokenCodable: MobileContentAuthTokenDecodable) async throws
    func deleteAuthToken(userId: String) async throws
    func getAuthTokenChangedPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel?, Never>
}
