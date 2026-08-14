//
//  LaunchCountDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct LaunchCountDataModel: Sendable {

    let id: String
    let launchCount: Int
}

extension LaunchCountDataModel: Equatable {
    static func == (this: LaunchCountDataModel, that: LaunchCountDataModel) -> Bool {
        return this.id == that.id && this.launchCount == that.launchCount
    }
}
