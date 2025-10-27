//
//  SwiftUserCounter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
typealias SwiftUserCounter = SwiftUserCounterV1.SwiftUserCounter

@available(iOS 17, *)
enum SwiftUserCounterV1 {
    
    @Model
    class SwiftUserCounter: IdentifiableSwiftDataObject {
        
        var latestCountFromAPI: Int = 0
        var incrementValue: Int = 0
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
