//
//  SwiftLaunchCountMapping.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftLaunchCountMapping: Mapping {

    func toDataModel(externalObject: LaunchCountDataModel) -> LaunchCountDataModel? {
        return externalObject
    }

    func toDataModel(persistObject: SwiftLaunchCount) -> LaunchCountDataModel? {
        return persistObject.toModel()
    }

    func toPersistObject(externalObject: LaunchCountDataModel) -> SwiftLaunchCount? {
        return SwiftLaunchCount.createNewFrom(model: externalObject)
    }
}
