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
    let languageCode: String
    let resourceId: String
    let webUrl: String
    let webArchiveFilename: String
    
    init(articleJcrContent: ArticleJcrContent?, languageCode: String, resourceId: String, webUrl: String, webArchiveFilename: String) {
        
        self.articleJcrContent = articleJcrContent
        self.languageCode = languageCode
        self.resourceId = resourceId
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
        
        languageCode = realmModel.languageCode
        resourceId = realmModel.resourceId
        webUrl = realmModel.webUrl
        webArchiveFilename = realmModel.webArchiveFilename
    }
}
