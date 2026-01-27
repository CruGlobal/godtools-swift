//
//  RealmPersonalizedToolsCacheSync.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class RealmPersonalizedToolsCacheSync {

    private let realmDatabase: LegacyRealmDatabase

    init(realmDatabase: LegacyRealmDatabase) {

        self.realmDatabase = realmDatabase
    }

    func syncPersonalizedTools(_ personalizedTools: [PersonalizedToolsDataModel]) -> AnyPublisher<[PersonalizedToolsDataModel], Error> {

        return realmDatabase.writeObjectsPublisher { (realm: Realm) in

            let newPersonalizedTools: [RealmPersonalizedTools] = personalizedTools.map { dataModel in

                let realmPersonalizedTools = RealmPersonalizedTools()
                realmPersonalizedTools.id = dataModel.id
                realmPersonalizedTools.updatedAt = dataModel.updatedAt
                realmPersonalizedTools.resourceIds.append(objectsIn: dataModel.resourceIds)

                return realmPersonalizedTools
            }

            return newPersonalizedTools

        } mapInBackgroundClosure: { (objects: [RealmPersonalizedTools]) in

            objects.map {
                PersonalizedToolsDataModel(realmObject: $0)
            }
        }
        .eraseToAnyPublisher()
    }
}
