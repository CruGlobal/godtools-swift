//
//  ArticleAemImportDataCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleAemImportDataCacheType {
    
    associatedtype ArticleAemImportDataAssociatedType = ArticleAemImportDataType
        
    func getArticleAemImportDataObjects(godToolsResource: GodToolsResource) -> [RealmArticleAemImportData]
    func getArticlesWithTags(godToolsResource: GodToolsResource, aemTags: [String]) -> [ArticleAemImportDataAssociatedType]
    func cache(articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ error: Error?) -> Void))
    func deleteAemImportDataObjects(godToolsResource: GodToolsResource) -> Error?
    func deleteAllAemImportDataObjects() -> Error?
}
