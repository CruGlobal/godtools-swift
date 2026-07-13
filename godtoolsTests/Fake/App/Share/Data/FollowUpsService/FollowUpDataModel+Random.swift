//
//  FollowUpDataModel+Random.swift
//  godtools
//
//  Created by Levi Eggert on 7/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension FollowUpDataModel {

    static func random(
        id: String = UUID().uuidString,
        name: String = String.random(),
        email: String = String.random(),
        destinationId: Int = Int.random(),
        languageId: Int = Int.random()
    ) -> FollowUpDataModel {

        return FollowUpDataModel(
            id: id,
            name: name,
            email: email,
            destinationId: destinationId,
            languageId: languageId
        )
    }
}
