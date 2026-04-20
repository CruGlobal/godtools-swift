//
//  ToolFilterLanguagesStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolFilterLanguagesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: ToolFilterLanguagesStringsDomainModel {
        return ToolFilterLanguagesStringsDomainModel(navTitle: "")
    }
}
