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
    
    @objc dynamic var articleJcrContent: RealmArticleJcrContent?
    @objc dynamic var id: String = ""
    @objc dynamic var webUrl: String = ""
    
    required init(articleJcrContent: RealmArticleJcrContent?, id: String, webUrl: String) {
        self.articleJcrContent = articleJcrContent
        self.id = id
        self.webUrl = webUrl
    }
    
    required init() {
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
