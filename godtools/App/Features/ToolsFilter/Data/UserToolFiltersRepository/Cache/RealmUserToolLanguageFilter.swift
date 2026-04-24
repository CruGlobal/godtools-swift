//
//  RealmUserToolLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserToolLanguageFilter: Object, IdentifiableRealmObject {
    
    @objc dynamic var filterId: String = ""
    @objc dynamic var languageId: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    @objc dynamic var id: String {
        get {
            return filterId
        }
        set {
            filterId = newValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "filterId"
    }
}

extension RealmUserToolLanguageFilter {
    
    func mapFrom(model: UserToolLanguageFilterDataModel) {
        
        id = model.id
        filterId = model.filterId
        languageId = model.languageId
        createdAt = model.createdAt
    }
    
    static func createNewFrom(model: UserToolLanguageFilterDataModel) -> RealmUserToolLanguageFilter {
        
        let object = RealmUserToolLanguageFilter()
        object.mapFrom(model: model)
        return object
    }
 
    func toModel() -> UserToolLanguageFilterDataModel {
        return UserToolLanguageFilterDataModel(
            id: id,
            filterId: filterId,
            languageId: languageId,
            createdAt: createdAt
        )
    }
}
