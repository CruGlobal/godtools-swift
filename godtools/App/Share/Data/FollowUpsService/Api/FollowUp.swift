//
//  FollowUp.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FollowUp: Sendable {
    
    let name: String
    let email: String
    let destinationId: Int
    let languageId: Int
}

extension FollowUp {
    func toModel(id: String) -> FollowUpDataModel {
        return FollowUpDataModel(
            id: id,
            name: name,
            email: email,
            destinationId: destinationId,
            languageId: languageId
        )
    }
}
