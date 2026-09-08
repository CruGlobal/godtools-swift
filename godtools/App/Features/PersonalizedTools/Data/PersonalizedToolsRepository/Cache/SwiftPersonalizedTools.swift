//
//  SwiftPersonalizedTools.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftPersonalizedTools = SwiftPersonalizedToolsV1.SwiftPersonalizedTools

@available(iOS 17.4, *)
enum SwiftPersonalizedToolsV1 {

    @Model
    class SwiftPersonalizedTools: IdentifiableSwiftDataObject {

        var resourceIds: [String] = Array<String>()
        var updatedAt: Date = Date()

        @Attribute(.unique) var id: String = ""

        init() {

        }
    }
}

@available(iOS 17.4, *)
extension SwiftPersonalizedTools {
    
    public static func idPredicate(id: String) -> Predicate<SwiftPersonalizedTools> {
        return #Predicate<SwiftPersonalizedTools> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftPersonalizedTools> {
        return #Predicate<SwiftPersonalizedTools> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: PersonalizedToolsDataModel) {
        id = model.id
        resourceIds = model.resourceIds
        updatedAt = model.updatedAt
    }

    static func createNewFrom(model: PersonalizedToolsDataModel) -> SwiftPersonalizedTools {
        let object = SwiftPersonalizedTools()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> PersonalizedToolsDataModel {
        return PersonalizedToolsDataModel(
            id: id,
            resourceIds: resourceIds,
            updatedAt: updatedAt
        )
    }
}
