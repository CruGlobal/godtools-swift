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
    private let numberOfAppLanguages: Int
    
    init(realmDatabase: RealmDatabase, numberOfAppLanguages: Int) {
        
        self.realmDatabase = realmDatabase
        self.numberOfAppLanguages = numberOfAppLanguages
    }
    
    func syncPublisher() -> AnyPublisher<Void, Never> {
        
        let allAppLanguages: [AppLanguageCodable] = [
            AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans"),
            AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hant"),
            AppLanguageCodable(languageCode: "lv", languageDirection: .leftToRight, languageScriptCode: nil)
        ]
        
        if allAppLanguages.count != numberOfAppLanguages {
            assertionFailure("numberOfAppLanguages should equal allAppLanguages.count for tests.")
        }
        
        _ = realmDatabase.writeObjects(realm: realmDatabase.openRealm()) { (realm: Realm) in
            
            let realmLanguages: [RealmAppLanguage] = allAppLanguages.map({
                
                let realmAppLanguage = RealmAppLanguage()
                realmAppLanguage.mapFrom(dataModel: $0)
                return realmAppLanguage
            })
            
            return realmLanguages
        }
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
