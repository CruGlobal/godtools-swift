//
//  LanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesRepository {
    
    private let cache: RealmLanguagesCache
    
    required init(cache: RealmLanguagesCache) {
        
        self.cache = cache
    }
    
    func getLanguage(id: String) -> LanguageModel? {
        
        guard let realmLanguage = cache.getLanguage(id: id) else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
    
    func getLanguage(code: String) -> LanguageModel? {
        
        guard let realmLanguage = cache.getLanguage(code: code) else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
    
    func getLanguages(ids: [String]) -> [LanguageModel] {
        
        var languages: [LanguageModel] = Array()
        
        for id in ids {
            
            guard let realmLanguage = cache.getLanguage(id: id) else {
                continue
            }
            
            languages.append(LanguageModel(model: realmLanguage))
        }
        
        return languages
    }
    
    func getAllLanguages() -> [LanguageModel] {
        
        return cache.getLanguages().map({LanguageModel(model: $0)})
    }
}
