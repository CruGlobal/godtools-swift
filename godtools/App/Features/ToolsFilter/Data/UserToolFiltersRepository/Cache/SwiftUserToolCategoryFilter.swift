//
//  SwiftUserToolCategoryFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserToolCategoryFilter = SwiftUserToolCategoryFilterV1.SwiftUserToolCategoryFilter

@available(iOS 17.4, *)
enum SwiftUserToolCategoryFilterV1 {
    
    @Model
    class SwiftUserToolCategoryFilter: IdentifiableSwiftDataObject {
                
        var createdAt: Date = Date()
        var categoryId: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var filterId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserToolCategoryFilter {
    
    func mapFrom(model: UserToolCategoryFilterDataModel) {
        
        id = model.id
        filterId = model.filterId
        categoryId = model.categoryId
        createdAt = model.createdAt
    }
    
    static func createNewFrom(model: UserToolCategoryFilterDataModel) -> SwiftUserToolCategoryFilter {
        
        let object = SwiftUserToolCategoryFilter()
        object.mapFrom(model: model)
        return object
    }
 
    func toModel() -> UserToolCategoryFilterDataModel {
        return UserToolCategoryFilterDataModel(
            id: id,
            filterId: filterId,
            categoryId: categoryId,
            createdAt: createdAt
        )
    }
}
