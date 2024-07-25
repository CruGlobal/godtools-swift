//
//  CategoryFilterDomainModelInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol CategoryFilterDomainModelInterface: StringSearchable {
    
    var id: String? { get }
    var filterId: String { get }
    var categoryButtonText: String { get }
    var primaryText: String { get }
    var toolsAvailableText: String { get }
}
