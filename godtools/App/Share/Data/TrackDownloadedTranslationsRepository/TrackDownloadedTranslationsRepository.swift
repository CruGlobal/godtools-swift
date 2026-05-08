//
//  TrackDownloadedTranslationsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class TrackDownloadedTranslationsRepository {
    
    private let cache: TrackDownloadedTranslationsCache
    
    init(cache: TrackDownloadedTranslationsCache) {
        
        self.cache = cache
    }
    
    func getLatestDownloadedTranslation(resourceId: String, languageId: String) throws -> DownloadedTranslationDataModel? {
        
        return try cache.getLatestDownloadedTranslation(
            resourceId: resourceId,
            languageId: languageId
        )
    }
    
    func trackTranslationDownloaded(translation: TranslationDataModel) async throws -> [DownloadedTranslationDataModel] {
        
        return try await self.cache.trackTranslationDownloaded(translation: translation)
    }
}
