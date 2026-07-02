//
//  ToolFilterCategoriesStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolFilterCategoriesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: ToolFilterCategoriesStringsDomainModel {
        return ToolFilterCategoriesStringsDomainModel(navTitle: "")
    }
}
