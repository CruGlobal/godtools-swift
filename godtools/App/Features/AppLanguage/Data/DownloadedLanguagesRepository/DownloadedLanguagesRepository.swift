//
//  DownloadedLanguagesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadedLanguagesRepository {
    
    private let cache: RealmDownloadedLanguagesCache
    
    init(cache: RealmDownloadedLanguagesCache) {
        
        self.cache = cache
    }
    
    func storeDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel, Error> {
        
        return cache.storeDownloadedLanguage(languageId: languageId)
    }
    
    func deleteDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<Void, Error> {
        
        return cache.deleteDownloadedLanguage(languageId: languageId)
    }
}
