//
//  ResourceViewDataModel+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension ResourceViewDataModel {

    static func random(
        id: String = UUID().uuidString,
        resourceId: String = UUID().uuidString,
        quantity: Int = Int.random()
    ) -> ResourceViewDataModel {

        return ResourceViewDataModel(
            id: id,
            resourceId: resourceId,
            quantity: quantity
        )
    }
}
