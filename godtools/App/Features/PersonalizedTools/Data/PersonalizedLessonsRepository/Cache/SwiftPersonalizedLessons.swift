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
    class SwiftPersonalizedLessons: IdentifiableSwiftDataObject, PersonalizedLessonsDataModelInterface {
        
        var resourceIds: [String] = Array<String>()
        var updatedAt: Date = Date()
        
        @Attribute(.unique) var id: String = ""
                                
        init() {
            
        }
        
        func getResourceIds() -> [String] {
            return resourceIds
        }
        
        func mapFrom(interface: PersonalizedLessonsDataModelInterface) {
            id = interface.id
            resourceIds = interface.getResourceIds()
            updatedAt = interface.updatedAt
        }
        
        static func createNewFrom(interface: PersonalizedLessonsDataModelInterface) -> SwiftPersonalizedLessons {
            let object = SwiftPersonalizedLessons()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
