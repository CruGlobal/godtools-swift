//
//  ReorderFavoritedToolDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ReorderFavoritedToolDomainModel: Sendable {
    
    let dataModelId: String
    let position: Int
}

extension ReorderFavoritedToolDomainModel: Identifiable {
    
    var id: String {
        return dataModelId
    }
}
