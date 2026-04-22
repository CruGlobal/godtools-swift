//
//  SwiftArticleJrcContent.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftArticleJrcContent = SwiftArticleJrcContentV1.SwiftArticleJrcContent

@available(iOS 17.4, *)
enum SwiftArticleJrcContentV1 {
 
    @Model
    class SwiftArticleJrcContent: IdentifiableSwiftDataObject {
        
        var aemUri: String = ""
        var canonical: String?
        var tags: [String] = Array<String>()
        var title: String?
        var uuid: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftArticleJrcContent {
    
    func mapFrom(model: ArticleJcrContent) {
        
        id = model.id
        aemUri = model.aemUri
        canonical = model.canonical
        tags = model.tags
        title = model.title
        uuid = model.uuid
    }
    
    static func createNewFrom(model: ArticleJcrContent) -> SwiftArticleJrcContent {
        
        let object = SwiftArticleJrcContent()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftArticleJrcContent {
    
    func toModel() -> ArticleJcrContent {
        return ArticleJcrContent(
            id: id,
            aemUri: aemUri,
            canonical: canonical,
            tags: Array(tags),
            title: title,
            uuid: uuid
        )
    }
}
