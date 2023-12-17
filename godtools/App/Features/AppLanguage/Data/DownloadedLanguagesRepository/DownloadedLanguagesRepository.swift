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
    
    func getDownloadedLanguagesPublisher() -> AnyPublisher<[DownloadedLanguageDataModel], Never> {
        
        return cache.getDownloadedLanguagesPublisher()
    }
    
    func getDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel?, Never> {
        
        return cache.getDownloadedLanguagePublisher(languageId: languageId)
    }
    
    func storeDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<DownloadedLanguageDataModel, Error> {
        
        return cache.storeDownloadedLanguagePublisher(languageId: languageId)
    }
    
    func deleteDownloadedLanguagePublisher(languageId: String) -> AnyPublisher<Void, Error> {
        
        return cache.deleteDownloadedLanguagePublisher(languageId: languageId)
    }
}
