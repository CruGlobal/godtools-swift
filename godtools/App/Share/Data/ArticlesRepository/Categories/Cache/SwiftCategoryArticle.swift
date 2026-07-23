//
//  SwiftCategoryArticle.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftCategoryArticle = SwiftCategoryArticleV1.SwiftCategoryArticle

@available(iOS 17.4, *)
enum SwiftCategoryArticleV1 {
 
    @Model
    class SwiftCategoryArticle: IdentifiableSwiftDataObject {
        
        var aemTag: String = ""
        var aemUris: [String] = Array<String>()
        var categoryId: String = ""
        var languageCode: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var uuid: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftCategoryArticle {
    
    public static func idPredicate(id: String) -> Predicate<SwiftCategoryArticle> {
        return #Predicate<SwiftCategoryArticle> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftCategoryArticle> {
        return #Predicate<SwiftCategoryArticle> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: CategoryArticleDataModel) {
        
        id = model.id
        aemTag = model.aemTag
        categoryId = model.categoryId
        languageCode = model.languageCode
        uuid = model.uuid.uuidString
        aemUris = model.aemUris
    }
    
    static func createNewFrom(model: CategoryArticleDataModel) -> SwiftCategoryArticle {
        let object = SwiftCategoryArticle()
        object.mapFrom(model: model)
        return object
    }
   
    func toModel() -> CategoryArticleDataModel {
        return CategoryArticleDataModel(
            id: id,
            aemTag: aemTag,
            aemUris: Array(aemUris),
            categoryId: categoryId,
            languageCode: languageCode
        )
    }
}
