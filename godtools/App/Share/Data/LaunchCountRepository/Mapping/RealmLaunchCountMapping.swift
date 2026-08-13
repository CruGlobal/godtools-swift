//
//  RealmLaunchCountMapping.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmLaunchCountMapping: Mapping {

    func toDataModel(externalObject: LaunchCountDataModel) -> LaunchCountDataModel? {
        return externalObject
    }

    func toDataModel(persistObject: RealmLaunchCount) -> LaunchCountDataModel? {
        return persistObject.toModel()
    }

    func toPersistObject(externalObject: LaunchCountDataModel) -> RealmLaunchCount? {
        return RealmLaunchCount.createNewFrom(model: externalObject)
    }
}
