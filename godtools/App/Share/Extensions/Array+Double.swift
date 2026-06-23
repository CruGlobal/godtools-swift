//
//  Array+Double.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension Array where Element == Double {
    
    func getAverage() -> Double {
        
        let count: Int = self.count
        
        guard count > 0 else {
            return 0
        }
        
        let sum: Double = reduce(0, +)
        
        let average: Double = sum / Double(count)
        
        return average
    }
}
