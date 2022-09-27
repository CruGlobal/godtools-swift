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
    
    func getDownloadedTranslation(translationId: String) -> DownloadedTranslationDataModel? {
        return cache.getDownloadedTranslation(translationId: translationId)
    }
    
    func trackTranslationDownloaded(translationId: String) -> AnyPublisher<String, Error> {
        return cache.trackTranslationDownloaded(translationId: translationId)
    }
}
