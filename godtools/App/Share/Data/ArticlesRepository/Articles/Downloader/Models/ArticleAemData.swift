//
//  ArticleAemData.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemData: Sendable {
    
    private let htmlExtension: String = "html"
    private let internalWebUrl: String
    
    let id: String
    let aemUri: String
    let articleJcrContent: ArticleJcrContent?
    let updatedAt: Date
    
    init(id: String, aemUri: String, articleJcrContent: ArticleJcrContent?, webUrl: String, updatedAt: Date) {
        
        self.id = id
        self.aemUri = aemUri
        self.articleJcrContent = articleJcrContent
        self.internalWebUrl = webUrl
        self.updatedAt = updatedAt
    }
    
    var webUrl: String {
        return internalWebUrl.replacingOccurrences(of: "/.\(htmlExtension)", with: ".\(htmlExtension)")        
    }
}
