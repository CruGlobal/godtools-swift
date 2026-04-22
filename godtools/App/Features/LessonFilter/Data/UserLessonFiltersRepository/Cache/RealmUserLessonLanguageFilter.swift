//
//  RealmUserLessonLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserLessonLanguageFilter: Object, IdentifiableRealmObject {
        
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var languageId: String = ""
    @objc dynamic var filterId: String = ""
    
    override static func primaryKey() -> String? {
        return "filterId"
    }
}

extension RealmUserLessonLanguageFilter {
    
    func mapFrom(model: UserLessonLanguageFilterDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        languageId = model.languageId
        filterId = model.filterId
    }
    
    static func createNewFrom(model: UserLessonLanguageFilterDataModel) -> RealmUserLessonLanguageFilter {
        
        let object = RealmUserLessonLanguageFilter()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmUserLessonLanguageFilter {
 
    func toModel() -> UserLessonLanguageFilterDataModel {
        return UserLessonLanguageFilterDataModel(
            id: id,
            createdAt: createdAt,
            languageId: languageId,
            filterId: filterId
        )
    }
}
