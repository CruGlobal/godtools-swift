//
//  PullToRefreshArticlesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

final class PullToRefreshArticlesUseCase {
    
    private let articleManifestAemRepository: ArticleManifestAemRepository
    
    init(articleManifestAemRepository: ArticleManifestAemRepository) {
        
        self.articleManifestAemRepository = articleManifestAemRepository
    }
    
    func execute(translation: TranslationDataModel, language: LanguageDataModel, manifest: Manifest) async throws {
        
        try await articleManifestAemRepository.downloadAndCacheManifestAemUris(
            manifest: manifest,
            translationId: translation.id,
            languageCode: language.localeId,
            downloadCachePolicy: .ignoreCache,
            requestPriority: .high,
            forceFetchFromRemote: true
        )
    }
}
