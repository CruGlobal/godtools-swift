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
    class SwiftPersonalizedTools: IdentifiableSwiftDataObject, PersonalizedToolsDataModelInterface {

        var resourceIds: [String] = Array<String>()
        var updatedAt: Date = Date()

        @Attribute(.unique) var id: String = ""

        init() {

        }

        func getResourceIds() -> [String] {
            return resourceIds
        }

        func mapFrom(interface: PersonalizedToolsDataModelInterface) {
            id = interface.id
            resourceIds = interface.getResourceIds()
            updatedAt = interface.updatedAt
        }

        static func createNewFrom(interface: PersonalizedToolsDataModelInterface) -> SwiftPersonalizedTools {
            let object = SwiftPersonalizedTools()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
