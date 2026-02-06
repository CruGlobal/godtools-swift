//
//  RealmPersonalizedLessonsCacheSync.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class RealmPersonalizedLessonsCacheSync {

    private let realmDatabase: LegacyRealmDatabase

    init(realmDatabase: LegacyRealmDatabase) {

        self.realmDatabase = realmDatabase
    }

    func syncPersonalizedLessons(_ personalizedLessons: [PersonalizedLessonsDataModel]) -> AnyPublisher<[PersonalizedLessonsDataModel], Error> {

        return realmDatabase.writeObjectsPublisher { (realm: Realm) in

            let newPersonalizedLessons: [RealmPersonalizedLessons] = personalizedLessons.map { dataModel in

                let realmPersonalizedLessons = RealmPersonalizedLessons()
                realmPersonalizedLessons.id = dataModel.id
                realmPersonalizedLessons.updatedAt = dataModel.updatedAt
                realmPersonalizedLessons.resourceIds.append(objectsIn: dataModel.resourceIds)

                return realmPersonalizedLessons
            }

            return newPersonalizedLessons

        } mapInBackgroundClosure: { (objects: [RealmPersonalizedLessons]) in

            objects.map {
                PersonalizedLessonsDataModel(realmObject: $0)
            }
        }
        .eraseToAnyPublisher()
    }
}
