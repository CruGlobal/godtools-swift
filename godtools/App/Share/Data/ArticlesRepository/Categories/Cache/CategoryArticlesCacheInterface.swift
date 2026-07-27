//
//  CategoryArticlesCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol CategoryArticlesCacheInterface {
    
    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleDataModel]
    
    func storeAemDataObjectsForCategories(
        categories: [ManifestCategory],
        languageCode: String,
        aemDataObjects: [ArticleAemData]
    ) async -> [Error]
}
