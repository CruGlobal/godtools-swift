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
    
    private let cache: RealmAppLanguagesCache
    
    init(cache: RealmAppLanguagesCache) {
        
        self.cache = cache
    }
    
    func getNumberOfCachedLanguages() -> Int {
        return cache.getNumberOfLanguages()
    }
    
    func getLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.getLanguagesChangedPublisher()
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageDataModel], Never> {
        return cache.getLanguagesPublisher()
    }

    func getLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<AppLanguageDataModel?, Never> {
        return cache.getLanguagePublisher(languageId: languageId)
    }
}

extension AppLanguagesRepository {
    
    func syncAllAppLanguages() -> AnyPublisher<[AppLanguageDataModel], Never> {
        
        let allAppLanguages: [AppLanguageDataModel] = [
            AppLanguageDataModel(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "pt", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "fr", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "id", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageDataModel(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageDataModel(languageCode: "hi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "ru", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "vi", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "bn", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageDataModel(languageCode: "ur", languageDirection: .rightToLeft, languageScriptCode: nil)
        ]
        
        return cache.storeLanguagesPublisher(appLanguages: allAppLanguages)
            .catch({ _ in
                return Just([])
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
