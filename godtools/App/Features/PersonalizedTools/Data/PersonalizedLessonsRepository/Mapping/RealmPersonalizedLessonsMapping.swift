//
//  RealmPersonalizedLessonsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmPersonalizedLessonsMapping: Mapping {
    
    func toDataModel(externalObject: PersonalizedLessonsDataModel) -> PersonalizedLessonsDataModel? {
        return PersonalizedLessonsDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmPersonalizedLessons) -> PersonalizedLessonsDataModel? {
        return PersonalizedLessonsDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: PersonalizedLessonsDataModel) -> RealmPersonalizedLessons? {
        return RealmPersonalizedLessons.createNewFrom(interface: externalObject)
    }
}
