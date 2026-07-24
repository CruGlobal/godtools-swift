//
//  ArticleAemCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ArticleAemCacheInterface {

    func getArticleAemDataObjects() async throws -> [ArticleAemData]
    func getAemCacheObject(aemUri: String) async throws -> ArticleAemCacheObject?
    func getAemCacheObjects(aemUris: [String]) async throws -> [ArticleAemCacheObject]
    func storeAemDataObjects(
        aemDataObjects: [ArticleAemData],
        requestPriority: RequestPriority
    ) async throws -> [ArticleWebArchiveData]
}
