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
        
        var errorCode: Int? = nil
        var errorMessage: String? = nil
        var httpStatusCode: Int? = nil
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
    
    public static func idPredicate(id: String) -> Predicate<SwiftArticleAemData> {
        return #Predicate<SwiftArticleAemData> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftArticleAemData> {
        return #Predicate<SwiftArticleAemData> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: ArticleAemData) {
        
        id = model.id
        aemUri = model.aemUri
        
        if let articleJcrContentModel = model.articleJcrContent {
            articleJcrContent = SwiftArticleJrcContent.createNewFrom(model: articleJcrContentModel)
        }
        
        errorMessage = model.errorMessage
        webUrl = model.webUrl ?? ""
        updatedAt = model.updatedAt
    }
    
    static func createNewFrom(model: ArticleAemData) -> SwiftArticleAemData {
        
        let object = SwiftArticleAemData()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ArticleAemData {
        return ArticleAemData(
            aemUri: aemUri,
            articleJcrContent: articleJcrContent?.toModel(),
            webUrl: webUrl,
            error: nil,
            errorMessage: errorMessage,
            errorCode: errorCode,
            httpStatusCode: httpStatusCode,
            updatedAt: updatedAt
        )
    }
}
