//
//  ArticleAemRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ArticleAemRepositoryInterface: Sendable {

    func getArticleAemDataObjects() async throws -> [ArticleAemData]
    func getAemCacheObject(aemUri: String) async throws -> ArticleAemCacheObject?
    func getAemCacheObjects(aemUris: [String]) async throws -> [ArticleAemCacheObject]
    func downloadAndCache(
        aemUris: [String],
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority
    ) async throws -> ArticleAemDownload
}
