//
//  ToolsResultDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ToolsResultDomainModel {

    let tools: [ToolListItemDomainModel]
    let unavailableStrings: PersonalizedToolsUnavailableDomainModel?

    static var empty: ToolsResultDomainModel {
        ToolsResultDomainModel(
            tools: [],
            unavailableStrings: nil
        )
    }
}
