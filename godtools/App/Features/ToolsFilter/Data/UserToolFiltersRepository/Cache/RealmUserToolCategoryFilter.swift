//
//  RealmUserToolCategoryFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserToolCategoryFilter: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var filterId: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "filterId"
    }
}

extension RealmUserToolCategoryFilter {
    
    func mapFrom(model: UserToolCategoryFilterDataModel) {
        
        id = model.id
        filterId = model.filterId
        categoryId = model.categoryId
        createdAt = model.createdAt
    }
    
    static func createNewFrom(model: UserToolCategoryFilterDataModel) -> RealmUserToolCategoryFilter {
        
        let object = RealmUserToolCategoryFilter()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmUserToolCategoryFilter {
 
    func toModel() -> UserToolCategoryFilterDataModel {
        return UserToolCategoryFilterDataModel(
            id: id,
            filterId: filterId,
            categoryId: categoryId,
            createdAt: createdAt
        )
    }
}
