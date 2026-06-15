//
//  Task+Sleep.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    
    static func sleepHalfSecond() async throws {
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}
