//
//  PersonalizedLessonsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class PersonalizedLessonsCache {

    private let realmDatabase: LegacyRealmDatabase
    private let personalizedLessonsSync: RealmPersonalizedLessonsCacheSync

    init(realmDatabase: LegacyRealmDatabase, personalizedLessonsSync: RealmPersonalizedLessonsCacheSync) {
        self.realmDatabase = realmDatabase
        self.personalizedLessonsSync = personalizedLessonsSync
    }

    @MainActor func getPersonalizedLessonsChanged() -> AnyPublisher<Void, Never> {

        return realmDatabase.openRealm()
            .objects(RealmPersonalizedLessons.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }

    func getPersonalizedLessonsFor(country: String?, language: String) -> PersonalizedLessonsDataModel? {

        let id = RealmPersonalizedLessons.createId(country: country, language: language)

        guard let realmPersonalizedLessons = realmDatabase.openRealm()
            .object(ofType: RealmPersonalizedLessons.self, forPrimaryKey: id)
        else {
            return nil
        }

        return PersonalizedLessonsDataModel(realmObject: realmPersonalizedLessons)
    }

    func syncPersonalizedLessons(_ personalizedLessons: [PersonalizedLessonsDataModel]) -> AnyPublisher<[PersonalizedLessonsDataModel], Error> {

        return personalizedLessonsSync.syncPersonalizedLessons(personalizedLessons)
    }
}
