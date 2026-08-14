//
//  SwiftLaunchCount.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftLaunchCount = SwiftLaunchCountV1.SwiftLaunchCount

@available(iOS 17.4, *)
enum SwiftLaunchCountV1 {

    @Model
    class SwiftLaunchCount: IdentifiableSwiftDataObject {

        var launchCount: Int = 0

        @Attribute(.unique) var id: String = ""

        init() {

        }
    }
}

@available(iOS 17.4, *)
extension SwiftLaunchCount {

    public static func idPredicate(id: String) -> Predicate<SwiftLaunchCount> {
        return #Predicate<SwiftLaunchCount> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftLaunchCount> {
        return #Predicate<SwiftLaunchCount> { object in
            ids.contains(object.id)
        }
    }

    func mapFrom(model: LaunchCountDataModel) {

        id = model.id
        launchCount = model.launchCount
    }

    static func createNewFrom(model: LaunchCountDataModel) -> SwiftLaunchCount {

        let object = SwiftLaunchCount()
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
