//
//  ArticleAemImportData.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemImportData: ArticleAemImportDataType {
    
    let articleJcrContent: ArticleJcrContent?
    let webUrl: String
    let webArchiveFilename: String
    
    init(articleJcrContent: ArticleJcrContent?, webUrl: String, webArchiveFilename: String) {
        
        self.articleJcrContent = articleJcrContent
        self.webUrl = webUrl
        self.webArchiveFilename = webArchiveFilename
    }
    
    init(realmModel: RealmArticleAemImportData) {
        
        if let realmArticleJcrContent = realmModel.articleJcrContent {
            articleJcrContent = ArticleJcrContent(realmModel: realmArticleJcrContent)
        }
        else {
            articleJcrContent = nil
        }
        
        webUrl = realmModel.webUrl
        webArchiveFilename = realmModel.webArchiveFilename
    }
}
