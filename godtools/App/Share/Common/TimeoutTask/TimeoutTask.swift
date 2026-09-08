//
//  TimeoutTask.swift
//  godtools
//
//  Created by Levi Eggert on 8/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class TimeoutTask: Sendable {
    
    private let task: Task<Void, Never>
    
    init(timeoutIntervalSeconds: TimeInterval, didTimeoutClosure: @escaping @Sendable () async -> Void) {
        
        self.task = Task {
            
            try? await Task.sleep(for: .seconds(timeoutIntervalSeconds))
            
            guard !Task.isCancelled else {
                return
            }
            
            await didTimeoutClosure()
        }
    }
    
    func cancel() {
        
        task.cancel()
    }
}
