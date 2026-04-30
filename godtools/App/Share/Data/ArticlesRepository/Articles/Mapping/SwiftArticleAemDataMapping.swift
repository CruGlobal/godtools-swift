//
//  SwiftArticleAemDataMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftArticleAemDataMapping: Mapping {
    
    func toDataModel(externalObject: ArticleAemData) -> ArticleAemData? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftArticleAemData) -> ArticleAemData? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ArticleAemData) -> SwiftArticleAemData? {
        return SwiftArticleAemData.createNewFrom(model: externalObject)
    }
}
