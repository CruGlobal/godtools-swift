//
//  SwiftArticleAemData.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftArticleAemData = SwiftArticleAemDataV1.SwiftArticleAemData

@available(iOS 17.4, *)
enum SwiftArticleAemDataV1 {

    @Model
    class SwiftArticleAemData: IdentifiableSwiftDataObject {
        
        var webUrl: String = ""
        var webArchiveFilename: String = ""
        var updatedAt: Date = Date()
        
        @Attribute(.unique) var aemUri: String = ""
        @Attribute(.unique) var id: String = ""
        
        @Relationship(deleteRule: .nullify) var articleJcrContent: SwiftArticleJrcContent?
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftArticleAemData {
    
    func mapFrom(model: ArticleAemData, ignorePrimaryKey: Bool) {
        
        if !ignorePrimaryKey {
            aemUri = model.aemUri
        }
        
        id = model.id
        
        if let articleJcrContentModel = model.articleJcrContent {
            articleJcrContent = SwiftArticleJrcContent.createNewFrom(model: articleJcrContentModel)
        }
        
        webUrl = model.webUrl
        updatedAt = model.updatedAt
    }
    
    static func createNewFrom(model: ArticleAemData) -> SwiftArticleAemData {
        
        let object = SwiftArticleAemData()
        object.mapFrom(model: model, ignorePrimaryKey: false)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftArticleAemData {
    
    func toModel() -> ArticleAemData {
        return ArticleAemData(
            id: id,
            aemUri: aemUri,
            articleJcrContent: articleJcrContent?.toModel(),
            webUrl: webUrl,
            updatedAt: updatedAt
        )
    }
}
