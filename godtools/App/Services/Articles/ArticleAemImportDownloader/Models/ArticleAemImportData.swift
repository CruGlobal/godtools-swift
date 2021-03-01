//
//  ArticleAemImportData.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemImportData: ArticleAemImportDataType {
    
    let aemUri: String
    let articleJcrContent: ArticleJcrContent?
    let webUrl: String
    let webArchiveFilename: String
    let updatedAt: Date
    
    init(aemUri: String, articleJcrContent: ArticleJcrContent?, webUrl: String, webArchiveFilename: String, updatedAt: Date) {
        
        self.aemUri = aemUri
        self.articleJcrContent = articleJcrContent
        self.webUrl = webUrl
        self.webArchiveFilename = webArchiveFilename
        self.updatedAt = updatedAt
    }
    
    init(realmModel: RealmArticleAemImportData) {
        
        aemUri = realmModel.aemUri
        if let realmArticleJcrContent = realmModel.articleJcrContent {
            articleJcrContent = ArticleJcrContent(realmModel: realmArticleJcrContent)
        }
        else {
            articleJcrContent = nil
        }
        
        webUrl = realmModel.webUrl
        webArchiveFilename = realmModel.webArchiveFilename
        updatedAt = realmModel.updatedAt
    }
}
