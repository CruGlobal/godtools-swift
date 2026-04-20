//
//  SwiftPersonalizedLessons.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftPersonalizedLessons = SwiftPersonalizedLessonsV1.SwiftPersonalizedLessons

@available(iOS 17.4, *)
enum SwiftPersonalizedLessonsV1 {
 
    @Model
    class SwiftPersonalizedLessons: IdentifiableSwiftDataObject {
        
        var resourceIds: [String] = Array<String>()
        var updatedAt: Date = Date()
        
        @Attribute(.unique) var id: String = ""
                                
        init() {
            
        }
        
        func mapFrom(model: PersonalizedLessonsDataModel) {
            id = model.id
            resourceIds = model.resourceIds
            updatedAt = model.updatedAt
        }
        
        static func createNewFrom(model: PersonalizedLessonsDataModel) -> SwiftPersonalizedLessons {
            let object = SwiftPersonalizedLessons()
            object.mapFrom(model: model)
            return object
        }
    }
}

@available(iOS 17.4, *)
extension SwiftPersonalizedLessons {
    
    func toModel() -> PersonalizedLessonsDataModel {
        return PersonalizedLessonsDataModel(
            id: id,
            updatedAt: updatedAt,
            resourceIds: resourceIds
        )
    }
}
