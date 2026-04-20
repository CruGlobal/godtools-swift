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
    class SwiftUserCounter: IdentifiableSwiftDataObject {
        
        var count: Int = 0
        var localCount: Int = 0
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
        
        func mapFrom(model: UserCounterDataModel) {
            count = model.count
            id = model.id
        }
        
        static func createNewFrom(model: UserCounterDataModel) -> SwiftUserCounter {
            let object = SwiftUserCounter()
            object.mapFrom(model: model)
            return object
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserCounter {
    
    func toModel() -> UserCounterDataModel {
        return UserCounterDataModel(
            id: id,
            count: count
        )
    }
}
