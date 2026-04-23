//
//  RealmArticleJcrContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmArticleJcrContent: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var aemUri: String = ""
    @objc dynamic var canonical: String?
    @objc dynamic var title: String?
    @objc dynamic var uuid: String?
    
    let tags = List<String>()
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

extension RealmArticleJcrContent {
    
    func mapFrom(model: ArticleJcrContent) {
        
        id = model.id
        aemUri = model.aemUri
        canonical = model.canonical
        title = model.title
        uuid = model.uuid
        
        tags.removeAll()
        tags.append(objectsIn: model.tags)
    }
    
    static func createNewFrom(model: ArticleJcrContent) -> RealmArticleJcrContent {
        
        let object = RealmArticleJcrContent()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ArticleJcrContent {
        return ArticleJcrContent(
            id: id,
            aemUri: aemUri,
            canonical: canonical,
            tags: Array(tags),
            title: title,
            uuid: uuid
        )
    }
}
