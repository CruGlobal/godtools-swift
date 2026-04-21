//
//  DatabaseChangesSleep.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    
    static func databaseChangesSleep() async throws {
        
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }
}
