//
//  MockSyncInvalidator.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

final class MockSyncInvalidator: SyncInvalidatorInterface {
    
    private(set) var shouldSync: Bool = false
    
    init() {
        
    }
    
    func didSync() {
        shouldSync = false
    }
    
    func resetSync() {
        shouldSync = true
    }
}
