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
import RepositorySync

class MockAppLanguagesRepositorySync: AppLanguagesRepositorySyncInterface {
    
    private let realmDatabase: RealmDatabase
    private let appLanguages: [AppLanguageCodable]
    
    init(realmDatabase: RealmDatabase, appLanguages: [AppLanguageCodable]) throws {
        
        self.realmDatabase = realmDatabase
        self.appLanguages = appLanguages
        
        try addAppLanguagesToRealm(appLanguages: appLanguages)
    }
    
    func syncPublisher() -> AnyPublisher<Void, Error> {
                
        guard appLanguages.isEmpty else {
            return Just(Void())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        do {
            
            try addAppLanguagesToRealm(appLanguages: appLanguages)
            
            return Just(Void())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func addAppLanguagesToRealm(appLanguages: [AppLanguageCodable]) throws {
        
        let realmLanguages: [RealmAppLanguage] = appLanguages.map({
            
            let realmAppLanguage = RealmAppLanguage()
            realmAppLanguage.mapFrom(interface: $0)
            return realmAppLanguage
        })
        
        let realm: Realm = try realmDatabase.openRealm()
        
        try realmDatabase.write.realm(
            realm: realm,
            writeClosure: { (realm: Realm) in
                return WriteRealmObjects(
                    deleteObjects: nil,
                    addObjects: realmLanguages
                )
            },
            updatePolicy: .modified
        )
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
