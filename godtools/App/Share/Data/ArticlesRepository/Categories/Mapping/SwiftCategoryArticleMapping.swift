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
    
    func toDataModel(externalObject: CategoryArticleDataModel) -> CategoryArticleDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftCategoryArticle) -> CategoryArticleDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: CategoryArticleDataModel) -> SwiftCategoryArticle? {
        return SwiftCategoryArticle.createNewFrom(model: externalObject)
    }
}
