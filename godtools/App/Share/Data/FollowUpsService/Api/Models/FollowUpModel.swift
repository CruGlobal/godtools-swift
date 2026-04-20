//
//  FollowUpModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FollowUpModel: Sendable {
    
    let id: String
    let name: String
    let email: String
    let destinationId: Int
    let languageId: Int
}
