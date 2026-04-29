//
//  SwiftCategoryArticleMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftCategoryArticleMapping: Mapping {
    
    func toDataModel(externalObject: CategoryArticleModel) -> CategoryArticleModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftCategoryArticle) -> CategoryArticleModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: CategoryArticleModel) -> SwiftCategoryArticle? {
        return SwiftCategoryArticle.createNewFrom(model: externalObject)
    }
}
