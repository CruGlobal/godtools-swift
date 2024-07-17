//
//  MockAppLanguagesRepositorySync.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import RealmSwift

class MockAppLanguagesRepositorySync: AppLanguagesRepositorySyncInterface {
    
    private let realmDatabase: RealmDatabase
    private let appLanguages: [AppLanguageCodable]
    
    init(realmDatabase: RealmDatabase, appLanguages: [AppLanguageCodable]) {
        
        self.realmDatabase = realmDatabase
        self.appLanguages = appLanguages
        
        addAppLanguagesToRealm(appLanguages: appLanguages)
    }
    
    func syncPublisher() -> AnyPublisher<Void, Never> {
                
        guard appLanguages.isEmpty else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
                
        addAppLanguagesToRealm(appLanguages: appLanguages)
        
        return Just(())
            .eraseToAnyPublisher()
    }
    
    private func addAppLanguagesToRealm(appLanguages: [AppLanguageCodable]) {
        
        _ = realmDatabase.writeObjects(realm: realmDatabase.openRealm()) { (realm: Realm) in
            
            let realmLanguages: [RealmAppLanguage] = appLanguages.map({
                
                let realmAppLanguage = RealmAppLanguage()
                realmAppLanguage.mapFrom(dataModel: $0)
                return realmAppLanguage
            })
            
            return realmLanguages
        }
    }
    
    static func getSampleAppLanguages() -> [AppLanguageCodable] {
        
        return [
            AppLanguageCodable(languageCode: "am", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ar", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "fa", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "he", languageDirection: .rightToLeft, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ja", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "pt", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "ru", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant")
        ]
    }
}
