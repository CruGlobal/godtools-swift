//
//  PersonalizedToolsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolsDomainModel: Sendable {

    let tools: [ToolListItemDomainModel]
    let unavailableStrings: PersonalizedToolsUnavailableDomainModel?

    static var emptyValue: PersonalizedToolsDomainModel {
        PersonalizedToolsDomainModel(
            tools: [],
            unavailableStrings: nil
        )
    }
}
