//
//  SwiftPersonalizedLessonsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftPersonalizedLessonsMapping: Mapping {
    
    func toDataModel(externalObject: PersonalizedLessonsDataModel) -> PersonalizedLessonsDataModel? {
        return PersonalizedLessonsDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftPersonalizedLessons) -> PersonalizedLessonsDataModel? {
        return PersonalizedLessonsDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: PersonalizedLessonsDataModel) -> SwiftPersonalizedLessons? {
        return SwiftPersonalizedLessons.createNewFrom(interface: externalObject)
    }
}
