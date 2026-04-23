//
//  FollowUpDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct FollowUpDataModel: Sendable {
    
    let id: String
    let name: String
    let email: String
    let destinationId: Int
    let languageId: Int
}

extension FollowUpDataModel {
    func toFollowUp() -> FollowUp {
        return FollowUp(name: name, email: email, destinationId: destinationId, languageId: languageId)
    }
}
