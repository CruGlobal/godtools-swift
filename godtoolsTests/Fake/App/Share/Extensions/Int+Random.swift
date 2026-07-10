//
//  Int+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension Int {
    
    static func random(min: Int = 0, max: Int = 10) -> Int {
        return Int.random(in: min...max)
    }
}
