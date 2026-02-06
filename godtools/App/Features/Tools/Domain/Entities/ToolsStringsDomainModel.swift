//
//  ToolsStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolsStringsDomainModel {

    let favoritingToolBannerMessage: String
    let toolSpotlightTitle: String
    let toolSpotlightSubtitle: String
    let filterTitle: String
    let personalizedToolToggleTitle: String
    let allToolsToggleTitle: String
    let personalizedToolExplanationTitle: String
    let personalizedToolExplanationSubtitle: String
    let changePersonalizedToolSettingsActionLabel: String

    static var emptyValue: ToolsStringsDomainModel {
        ToolsStringsDomainModel(favoritingToolBannerMessage: "", toolSpotlightTitle: "", toolSpotlightSubtitle: "", filterTitle: "", personalizedToolToggleTitle: "", allToolsToggleTitle: "", personalizedToolExplanationTitle: "", personalizedToolExplanationSubtitle: "", changePersonalizedToolSettingsActionLabel: "")
    }
}
