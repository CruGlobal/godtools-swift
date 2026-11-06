//
//  ToolsStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolsStringsDomainModel: Sendable {

    let title: String
    let allTitle: String
    let subtitle: String
    let favoritingToolBannerMessage: String
    let featuredToolsTitle: String
    let featuredToolsSubtitle: String
    let filterTitle: String
    let personalizedToolToggleTitle: String
    let allToolsToggleTitle: String
    let personalizedToolExplanationTitle: String
    let personalizedToolExplanationSubtitle: String
    let changePersonalizedToolSettingsAction: String
    let viewAllToolsAction: String

    static var emptyValue: ToolsStringsDomainModel {
        ToolsStringsDomainModel(title: "", allTitle: "", subtitle: "", favoritingToolBannerMessage: "", featuredToolsTitle: "", featuredToolsSubtitle: "", filterTitle: "", personalizedToolToggleTitle: "", allToolsToggleTitle: "", personalizedToolExplanationTitle: "", personalizedToolExplanationSubtitle: "", changePersonalizedToolSettingsAction: "", viewAllToolsAction: "")
    }
}
