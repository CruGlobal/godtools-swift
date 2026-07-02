//
//  RealmArticleAemDataMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmArticleAemDataMapping: Mapping {
    
    func toDataModel(externalObject: ArticleAemData) -> ArticleAemData? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmArticleAemData) -> ArticleAemData? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ArticleAemData) -> RealmArticleAemData? {
        return RealmArticleAemData.createNewFrom(model: externalObject)
    }
}
