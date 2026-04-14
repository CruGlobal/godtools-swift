//
//  SpotlightToolListItemDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct SpotlightToolListItemDomainModel: ToolListItemDomainModelInterface {
    
    let strings: ToolListItemStringsDomainModel
    let analyticsToolAbbreviation: String
    let dataModelId: String
    let bannerImageId: String
    let name: String
    let category: String
    let isFavorited: Bool
    let languageAvailability: ToolLanguageAvailabilityDomainModel?
}

extension SpotlightToolListItemDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
