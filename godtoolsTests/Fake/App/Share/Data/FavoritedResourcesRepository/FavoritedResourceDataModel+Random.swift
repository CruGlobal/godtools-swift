//
//  FavoritedResourceDataModel+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension FavoritedResourceDataModel {

    static func random(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        position: Int = Int.random()
    ) -> FavoritedResourceDataModel {

        return FavoritedResourceDataModel(
            id: id,
            createdAt: createdAt,
            position: position
        )
    }
}
