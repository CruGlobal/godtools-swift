//
//  UserCountersApiInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol UserCountersApiInterface: Sendable {
    
    func fetchUserCounters(requestPriority: RequestPriority) async throws -> [UserCounterCodable]
    func incrementUserCounter(id: String, increment: Int, requestPriority: RequestPriority) async throws -> UserCounterCodable
}
