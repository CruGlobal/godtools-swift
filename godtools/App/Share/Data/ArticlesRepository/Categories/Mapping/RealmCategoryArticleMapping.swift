//
//  RealmCategoryArticleMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmCategoryArticleMapping: Mapping {
    
    func toDataModel(externalObject: CategoryArticleModel) -> CategoryArticleModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmCategoryArticle) -> CategoryArticleModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: CategoryArticleModel) -> RealmCategoryArticle? {
        return RealmCategoryArticle.createNewFrom(model: externalObject)
    }
}
