//
//  AppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesRepository {
    
    private let cache: AppLanguagesCache
    
    init(cache: AppLanguagesCache) {
        
        self.cache = cache
    }
    
    func getNumberOfCachedLanguages() -> Int {
        return cache.getNumberOfLanguages()
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        
        let appLanguages: [AppLanguageDataModel] = cache.getAppLanguages()
        
        return Just(appLanguages)
            .eraseToAnyPublisher()
    }
    
    func getLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return Just(Void())
            .eraseToAnyPublisher()
    }

    func getLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<AppLanguageDataModel?, Never> {
        
        return getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<AppLanguageDataModel?, Never> in
                
                let language: AppLanguageDataModel? = languages.filter({
                    $0.languageId.lowercased() == languageId.lowercased()
                }).first
                
                return Just(language)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
