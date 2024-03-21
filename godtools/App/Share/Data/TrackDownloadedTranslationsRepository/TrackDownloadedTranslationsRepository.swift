//
//  TrackDownloadedTranslationsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackDownloadedTranslationsRepository {
    
    private let cache: TrackDownloadedTranslationsCache
    
    init(cache: TrackDownloadedTranslationsCache) {
        
        self.cache = cache
    }
    
    func getLatestDownloadedTranslation(resourceId: String, languageId: String) -> DownloadedTranslationDataModel? {
        return cache.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId)
    }
    
    func trackTranslationDownloaded(translation: TranslationModel) -> AnyPublisher<[DownloadedTranslationDataModel], Error> {
        return cache.trackTranslationDownloaded(translation: translation)
    }
}
