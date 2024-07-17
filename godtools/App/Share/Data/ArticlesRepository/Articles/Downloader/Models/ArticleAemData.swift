//
//  ArticleAemData.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemData: ArticleAemDataType {
    
    private let htmlExtension: String = "html"
    private let internalWebUrl: String
    
    let aemUri: String
    let articleJcrContent: ArticleJcrContent?
    let updatedAt: Date
    
    init(aemUri: String, articleJcrContent: ArticleJcrContent?, webUrl: String, updatedAt: Date) {
        
        self.aemUri = aemUri
        self.articleJcrContent = articleJcrContent
        self.internalWebUrl = webUrl
        self.updatedAt = updatedAt
    }
    
    init(realmModel: RealmArticleAemData) {
        
        aemUri = realmModel.aemUri
        if let realmArticleJcrContent = realmModel.articleJcrContent {
            articleJcrContent = ArticleJcrContent(realmModel: realmArticleJcrContent)
        }
        else {
            articleJcrContent = nil
        }
        
        internalWebUrl = realmModel.webUrl
        updatedAt = realmModel.updatedAt
    }
    
    var webUrl: String {
        return internalWebUrl.replacingOccurrences(of: "/.\(htmlExtension)", with: ".\(htmlExtension)")        
    }
}
