//
//  Collection+SafeLookup.swift
//  godtools
//
//  Created by Robert Eldredge on 2/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {
    
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
