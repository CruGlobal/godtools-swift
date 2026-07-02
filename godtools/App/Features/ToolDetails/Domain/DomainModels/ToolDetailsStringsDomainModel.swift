//
//  ToolDetailsStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolDetailsStringsDomainModel: Sendable {
    
    let aboutActionTitle: String
    let addToFavoritesActionTitle: String
    let bibleReferencesTitle: String
    let conversationStartersTitle: String
    let languagesAvailableTitle: String
    let learnToShareThisToolActionTitle: String
    let openToolActionTitle: String
    let outlineTitle: String
    let removeFromFavoritesActionTitle: String
    let versionsActionTitle: String
    
    static var emptyValue: ToolDetailsStringsDomainModel {
        return ToolDetailsStringsDomainModel(aboutActionTitle: "", addToFavoritesActionTitle: "", bibleReferencesTitle: "", conversationStartersTitle: "", languagesAvailableTitle: "", learnToShareThisToolActionTitle: "", openToolActionTitle: "", outlineTitle: "", removeFromFavoritesActionTitle: "", versionsActionTitle: "")
    }
}
