//
//  MockUserCountersApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RequestOperation

final class MockUserCountersApi: UserCountersApiInterface {
    
    func fetchUserCounters(requestPriority: RequestPriority) async throws -> [UserCounterCodable] {
        return Array()
    }
    
    func incrementUserCounter(id: String, increment: Int, requestPriority: RequestPriority) async throws -> UserCounterCodable {
        return UserCounterCodable(id: "", count: 1)
    }
}
