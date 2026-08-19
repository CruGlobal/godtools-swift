//
//  DidPullToRefreshAccountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class DidPullToRefreshAccountUseCase: Sendable {
    
    private let userDetailsSync: UserDetailsSync
    private let userCountersSync: UserCountersSync
    
    init(userDetailsSync: UserDetailsSync, userCountersSync: UserCountersSync) {
        
        self.userDetailsSync = userDetailsSync
        self.userCountersSync = userCountersSync
    }
    
    func execute() async throws {
        
        try await userDetailsSync.sync(requestPriority: .high)
        
        try await userCountersSync.sync(requestPriority: .high, forceSync: true)
    }
}
