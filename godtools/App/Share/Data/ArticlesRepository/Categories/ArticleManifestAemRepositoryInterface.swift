//
//  ArticleManifestAemRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import RequestOperation

protocol ArticleManifestAemRepositoryInterface: Sendable {

    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleDataModel]
    func getArticleAemDataObjects() async throws -> [ArticleAemData]
    func getAemCacheObject(aemUri: String) async throws -> ArticleAemCacheObject?
    func getAemCacheObjects(aemUris: [String]) async throws -> [ArticleAemCacheObject]
    func downloadAndCacheManifestAemUris(
        manifest: Manifest,
        translationId: String,
        languageCode: String,
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority,
        forceFetchFromRemote: Bool
    ) async throws -> ArticleAemDownload
}
