//
//  DidPullToRefreshAccountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class DidPullToRefreshAccountUseCase {
    
    private let userCountersSync: UserCountersSync
    
    init(userCountersSync: UserCountersSync) {
        
        self.userCountersSync = userCountersSync
    }
    
    func execute() -> AnyPublisher<Void, Error> {
        
        Task {
            try await userCountersSync.sync(requestPriority: .high, forceSync: true)
        }
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
