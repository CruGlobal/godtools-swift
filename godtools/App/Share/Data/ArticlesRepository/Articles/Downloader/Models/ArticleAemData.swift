//
//  ArticleAemData.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemData: Sendable {
        
    let id: String
    let aemUri: String
    let articleJcrContent: ArticleJcrContent?
    let webUrl: String
    let error: Error?
    let updatedAt: Date
    
    init(
        id: String,
        aemUri: String,
        articleJcrContent: ArticleJcrContent?,
        webUrl: String,
        error: Error?,
        updatedAt: Date
    ) {
        
        let htmlExtension: String = "html"
        
        self.id = id
        self.aemUri = aemUri
        self.articleJcrContent = articleJcrContent
        self.webUrl = webUrl.replacingOccurrences(of: "/.\(htmlExtension)", with: ".\(htmlExtension)")
        self.error = error
        self.updatedAt = updatedAt
    }
}
