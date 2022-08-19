//
//  Realm+SafeWrite.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
    func safeWrite(_ block: (() throws -> Void)) throws {
        
        if isInWriteTransaction {
            try block()
        }
        else {
            try write(block)
        }
    }
}
