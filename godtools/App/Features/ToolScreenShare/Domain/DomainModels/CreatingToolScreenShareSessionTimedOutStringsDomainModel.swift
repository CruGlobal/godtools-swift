//
//  CreatingToolScreenShareSessionTimedOutStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct CreatingToolScreenShareSessionTimedOutStringsDomainModel: Sendable {
    
    let title: String
    let message: String
    let acceptActionTitle: String
    
    static var emptyValue: CreatingToolScreenShareSessionTimedOutStringsDomainModel {
        return CreatingToolScreenShareSessionTimedOutStringsDomainModel(title: "", message: "", acceptActionTitle: "")
    }
}
