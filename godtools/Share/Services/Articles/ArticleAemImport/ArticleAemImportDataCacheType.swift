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
    
    var dataExistsInCache: Bool { get }
    
    func getArticlesWithTags(aemTags: [String]) -> [ArticleAemImportDataAssociatedType]
    func cache(articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ error: Error?) -> Void))
    func deleteAllData() -> Error?
}
