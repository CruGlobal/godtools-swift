//
//  RealmLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmLanguagesCache {
    
    private let realmDatabase: RealmDatabase
    private let languagesSync: RealmLanguagesCacheSync

    init(realmDatabase: RealmDatabase, languagesSync: RealmLanguagesCacheSync) {
        
        self.realmDatabase = realmDatabase
        self.languagesSync = languagesSync
    }
     
    func syncLanguages(languages: [LanguageCodable]) -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {

        return languagesSync.syncLanguages(languages: languages)
    }
}
