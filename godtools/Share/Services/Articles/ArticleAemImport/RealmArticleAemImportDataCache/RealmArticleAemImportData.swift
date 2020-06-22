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
    
    func mapFrom(model: ArticleAemImportData) {
        
        if let jcrContent = model.articleJcrContent {
            articleJcrContent = RealmArticleJcrContent()
            articleJcrContent?.mapFrom(model: jcrContent)
        }
        else {
            articleJcrContent = nil
        }
        
        languageCode = model.languageCode
        resourceId = model.resourceId
        webUrl = model.webUrl
        webArchiveFilename = model.webArchiveFilename
    }
}
