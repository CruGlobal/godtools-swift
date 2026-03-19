//
//  PersonalizedToolsDataModelInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol PersonalizedToolsDataModelInterface {

    var id: String { get }
    var updatedAt: Date { get }

    func getResourceIds() -> [String]
}
