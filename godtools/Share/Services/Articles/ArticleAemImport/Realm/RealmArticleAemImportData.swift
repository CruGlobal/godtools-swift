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
    @objc dynamic var languageCode: String = ""
    @objc dynamic var resourceId: String = ""
    @objc dynamic var webUrl: String = ""
    @objc dynamic var webArchiveFilename: String = ""
    
    required init(articleJcrContent: RealmArticleJcrContent?, languageCode: String, resourceId: String, webUrl: String, webArchiveFilename: String) {
        self.articleJcrContent = articleJcrContent
        self.languageCode = languageCode
        self.resourceId = resourceId
        self.webUrl = webUrl
        self.webArchiveFilename = webArchiveFilename
    }
    
    required init() {
        
    }
}
