//
//  MockOptInNotificationRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class MockOptInNotificationRepository: OptInNotificationRepositoryInterface {
    
    private let lastPromptedDate: Date?
    private let promptCount: Int
    
    init(lastPromptedDate: Date?, promptCount: Int) {
        
        self.lastPromptedDate = lastPromptedDate
        self.promptCount = promptCount
    }
    
    func getRemoteFeatureEnabled() -> Bool {
        return false
    }
    
    func getRemoteTimeInterval() -> Date {
        return Date()
    }
    
    func getRemotePromptLimit() -> Int {
        return 0
    }
    
    func getLastPrompted() -> Date? {
        return lastPromptedDate
    }
    
    func getPromptCount() -> Int {
        return promptCount
    }
    
    func recordPrompt() {
        
    }
}
