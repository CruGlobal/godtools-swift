//
//  PullToRefreshToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class PullToRefreshToolsUseCase {
    
    init() {
        
    }
    
    func execute() -> AnyPublisher<Void, Error> {
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
