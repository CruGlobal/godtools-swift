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
    
    func getData(tagId: String) -> [ArticleAemImportDataAssociatedType]
    func cache(articleAemImportData: ArticleAemImportData) -> Error?
    func deleteAllData() -> Error?
}
