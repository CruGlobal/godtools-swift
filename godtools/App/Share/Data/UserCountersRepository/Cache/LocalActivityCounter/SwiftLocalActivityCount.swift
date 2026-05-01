//
//  SwiftLocalActivityCount.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftLocalActivityCount = SwiftLocalActivityCountV1.SwiftLocalActivityCount

@available(iOS 17.4, *)
enum SwiftLocalActivityCountV1 {
    
    @Model
    class SwiftLocalActivityCount: IdentifiableSwiftDataObject {
        
        var count: Int = 0
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftLocalActivityCount {
    
    func mapFrom(model: LocalActivityCountDataModel) {
        id = model.id
        count = model.count
    }
    
    static func createNewFrom(model: LocalActivityCountDataModel) -> SwiftLocalActivityCount {
        let object = SwiftLocalActivityCount()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> LocalActivityCountDataModel {
        return LocalActivityCountDataModel(
            id: id,
            count: count
        )
    }
}
