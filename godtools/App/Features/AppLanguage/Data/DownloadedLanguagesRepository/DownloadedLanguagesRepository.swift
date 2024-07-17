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
    
    func getDownloadedLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return cache.getDownloadedLanguagesChangedPublisher()
    }
    
    func getDownloadedLanguagesPublisher(completedDownloadsOnly: Bool) -> AnyPublisher<[DownloadedLanguageDataModel], Never> {
        
        return cache.getDownloadedLanguagesPublisher(completedDownloadsOnly: completedDownloadsOnly)
    }
    
    func getDownloadedLanguage(languageId: String) -> DownloadedLanguageDataModel? {
        
        return cache.getDownloadedLanguage(languageId: languageId)
    }
    
    func getDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel?, Never> {
        
        return cache.getDownloadedLanguagePublisher(languageId: languageId)
    }
    
    func storeDownloadedLanguage(languageId: String, downloadComplete: Bool) {
        
        cache.storeDownloadedLanguage(languageId: languageId, downloadComplete: downloadComplete)
    }
    
    func storeDownloadedLanguagePublisher(languageId: String, downloadComplete: Bool) -> AnyPublisher<DownloadedLanguageDataModel, Error> {
        
        return cache.storeDownloadedLanguagePublisher(languageId: languageId, downloadComplete: downloadComplete)
    }
    
    func deleteDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<Void, Error> {
        
        return cache.deleteDownloadedLanguagePublisher(languageId: languageId)
    }
}
