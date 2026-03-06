//
//  SwiftUserCounter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserCounter = SwiftUserCounterV1.SwiftUserCounter

@available(iOS 17.4, *)
enum SwiftUserCounterV1 {
    
    @Model
    class SwiftUserCounter: IdentifiableSwiftDataObject, UserCounterDataModelInterface {
        
        var count: Int = 0
        var localCount: Int = 0
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
        
        func mapFrom(interface: UserCounterDataModelInterface) {
            count = interface.count
            id = interface.id
        }
        
        static func createNewFrom(interface: UserCounterDataModelInterface) -> SwiftUserCounter {
            let object = SwiftUserCounter()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
