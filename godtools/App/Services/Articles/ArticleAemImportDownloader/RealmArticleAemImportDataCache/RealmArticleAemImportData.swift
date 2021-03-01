//
//  RealmArticleAemImportData.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmArticleAemImportData: Object, ArticleAemImportDataType {
    
    @objc dynamic var aemUri: String = ""
    @objc dynamic var articleJcrContent: RealmArticleJcrContent?
    @objc dynamic var webUrl: String = ""
    @objc dynamic var webArchiveFilename: String = ""
    @objc dynamic var updatedAt: Date = Date()
    
    func mapFrom(model: ArticleAemImportData) {
        
        aemUri = model.aemUri
        
        if let jcrContent = model.articleJcrContent {
            articleJcrContent = RealmArticleJcrContent()
            articleJcrContent?.mapFrom(model: jcrContent)
        }
        else {
            articleJcrContent = nil
        }
        
        webUrl = model.webUrl
        webArchiveFilename = model.webArchiveFilename
        updatedAt = model.updatedAt
    }
    
    override static func primaryKey() -> String? {
        return "aemUri"
    }
}
