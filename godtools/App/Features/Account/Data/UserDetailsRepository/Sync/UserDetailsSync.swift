//
//  UserDetailsSync.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class UserDetailsSync: Sendable {
    
    private let api: UserDetailsApiInterface
    private let cache: UserDetailsCache
    
    init(api: UserDetailsApiInterface, cache: UserDetailsCache) {
        self.api = api
        self.cache = cache
    }
    
    func sync(requestPriority: RequestPriority) async throws {
        
        let codable: MobileContentApiUsersMeCodable = try await api.fetchUserDetails(requestPriority: requestPriority)
        
        _ = try await cache.persistence.writeObjects(
            externalObjects: [codable],
            writeOption: nil,
            getOption: nil
        )
    }
}
