//
//  RealmPersonalizedToolsMapping.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmPersonalizedToolsMapping: Mapping {

    func toDataModel(externalObject: PersonalizedToolsDataModel) -> PersonalizedToolsDataModel? {
        return PersonalizedToolsDataModel(interface: externalObject)
    }

    func toDataModel(persistObject: RealmPersonalizedTools) -> PersonalizedToolsDataModel? {
        return PersonalizedToolsDataModel(interface: persistObject)
    }

    func toPersistObject(externalObject: PersonalizedToolsDataModel) -> RealmPersonalizedTools? {
        return RealmPersonalizedTools.createNewFrom(interface: externalObject)
    }
}
