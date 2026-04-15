//
//  CreatingToolScreenShareSessionStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct CreatingToolScreenShareSessionStringsDomainModel: Sendable {
    
    let creatingSessionMessage: String
    
    static var emptyValue: CreatingToolScreenShareSessionStringsDomainModel {
        return CreatingToolScreenShareSessionStringsDomainModel(creatingSessionMessage: "")
    }
}
