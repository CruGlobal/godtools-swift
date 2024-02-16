//
//  YourFavoritedToolDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct YourFavoritedToolDomainModel: ToolListItemDomainModelInterface {
    
    let analyticsToolAbbreviation: String
    let dataModelId: String
    let bannerImageId: String
    let name: String
    let category: String
    let isFavorited: Bool
}

extension YourFavoritedToolDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
