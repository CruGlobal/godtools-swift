//
//  RealmLaunchCount.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmLaunchCount: Object, IdentifiableRealmObject {

    @objc dynamic var id: String = ""
    @objc dynamic var launchCount: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmLaunchCount {

    func mapFrom(model: LaunchCountDataModel) {

        id = model.id
        launchCount = model.launchCount
    }

    static func createNewFrom(model: LaunchCountDataModel) -> RealmLaunchCount {

        let object = RealmLaunchCount()
        object.mapFrom(model: model)
        return object
    }

    func toModel() -> LaunchCountDataModel {
        return LaunchCountDataModel(
            id: id,
            launchCount: launchCount
        )
    }
}
