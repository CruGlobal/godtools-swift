//
//  RealmArticleAemData.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmArticleAemData: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var aemUri: String = "" {
        didSet {
            id = aemUri
        }
    }
    @objc dynamic var articleJcrContent: RealmArticleJcrContent?
    @objc dynamic var webUrl: String = ""
    @objc dynamic var webArchiveFilename: String = ""
    @objc dynamic var updatedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "aemUri"
    }
}

extension RealmArticleAemData {
    
    func mapFrom(model: ArticleAemData) {
        
        id = model.id
        aemUri = model.aemUri
        if let articleJcrContentModel = model.articleJcrContent {
            articleJcrContent = RealmArticleJcrContent.createNewFrom(model: articleJcrContentModel)
        }
        
        webUrl = model.webUrl
        updatedAt = model.updatedAt
    }
    
    static func createNewFrom(model: ArticleAemData) -> RealmArticleAemData {
        
        let object = RealmArticleAemData()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ArticleAemData {
        return ArticleAemData(
            id: id,
            aemUri: aemUri,
            articleJcrContent: articleJcrContent?.toModel(),
            webUrl: webUrl,
            updatedAt: updatedAt
        )
    }
}
