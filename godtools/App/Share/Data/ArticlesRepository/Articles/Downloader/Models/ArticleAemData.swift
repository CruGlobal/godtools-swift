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
    let webUrl: String?
    let error: Error?
    let errorMessage: String?
    let errorCode: Int?
    let httpStatusCode: Int?
    let updatedAt: Date
    
    init(
        aemUri: String,
        articleJcrContent: ArticleJcrContent?,
        webUrl: String?,
        error: Error?,
        errorMessage: String?,
        errorCode: Int?,
        httpStatusCode: Int?,
        updatedAt: Date
    ) {
        
        let htmlExtension: String = "html"
        
        self.id = aemUri
        self.aemUri = aemUri
        self.articleJcrContent = articleJcrContent
        self.error = error
        self.errorMessage = error?.localizedDescription ?? errorMessage
        self.errorCode = error?.code ?? errorCode
        self.httpStatusCode = httpStatusCode
        self.updatedAt = updatedAt
        
        if let webUrl = webUrl, !webUrl.isEmpty {
            self.webUrl = webUrl.replacingOccurrences(of: "/.\(htmlExtension)", with: ".\(htmlExtension)")
        }
        else {
            self.webUrl = nil
        }
    }
    
    static func createWithError(
        aemUri: String,
        error: Error,
        httpStatusCode: Int?,
        updatedAt: Date = Date()
    ) -> ArticleAemData {
        
        return ArticleAemData(
            aemUri: aemUri,
            articleJcrContent: nil,
            webUrl: nil,
            error: error,
            errorMessage: nil,
            errorCode: error.code,
            httpStatusCode: httpStatusCode,
            updatedAt: updatedAt
        )
    }
}
