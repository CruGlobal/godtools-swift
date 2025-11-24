//
//  Array+Sorted.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    
    func sortedAscending() -> [Element] {
        return sorted(by: { $0 < $1 })
    }
}
