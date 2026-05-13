//
//  RealmCategoryArticle.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmCategoryArticle: Object, IdentifiableRealmObject {
    
    @objc dynamic var aemTag: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var languageCode: String = ""
    @objc dynamic var uuid: String = ""
    
    let aemUris = List<String>()
    
    @objc dynamic var id: String {
        get {
            return uuid
        }
        set {
            uuid = newValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

extension RealmCategoryArticle {
    
    func mapFrom(model: CategoryArticleModel) {
        
        id = model.id
        aemTag = model.aemTag
        categoryId = model.categoryId
        languageCode = model.languageCode
        uuid = model.uuid.uuidString
        aemUris.removeAll()
        aemUris.append(objectsIn: model.aemUris)
    }
    
    static func createNewFrom(model: CategoryArticleModel) -> RealmCategoryArticle {
        let object = RealmCategoryArticle()
        object.mapFrom(model: model)
        return object
    }
   
    func toModel() -> CategoryArticleModel {
        return CategoryArticleModel(
            id: id,
            aemTag: aemTag,
            aemUris: Array(aemUris),
            categoryId: categoryId,
            languageCode: languageCode
        )
    }
}
