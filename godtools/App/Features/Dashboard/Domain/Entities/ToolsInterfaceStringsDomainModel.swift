//
//  ToolsInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolsInterfaceStringsDomainModel {

    let favoritingToolBannerMessage: String
    let toolSpotlightTitle: String
    let toolSpotlightSubtitle: String
    let filterTitle: String
    let personalizedToolToggleTitle: String
    let allToolsToggleTitle: String
    let personalizedToolFooterTitle: String
    let personalizedToolFooterSubtitle: String
    let personalizedToolFooterButtonTitle: String
    
    static var emptyValue: ToolsInterfaceStringsDomainModel {
        ToolsInterfaceStringsDomainModel(favoritingToolBannerMessage: "", toolSpotlightTitle: "", toolSpotlightSubtitle: "", filterTitle: "", personalizedToolToggleTitle: "", allToolsToggleTitle: "", personalizedToolFooterTitle: "", personalizedToolFooterSubtitle: "", personalizedToolFooterButtonTitle: "")
    }
}
