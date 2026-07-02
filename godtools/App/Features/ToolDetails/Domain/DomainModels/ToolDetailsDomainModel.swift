//
//  ToolDetailsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolDetailsDomainModel: Sendable {
    
    let analyticsToolAbbreviation: String
    let aboutDescription: String
    let bibleReferences: String
    let conversationStarters: String
    let isFavorited: Bool
    let languagesAvailable: String
    let name: String
    let numberOfViews: String
    let versions: [ToolVersionDomainModel]
    let versionsDescription: String
    
    static var emptyValue: ToolDetailsDomainModel {
        return ToolDetailsDomainModel(analyticsToolAbbreviation: "", aboutDescription: "", bibleReferences: "", conversationStarters: "", isFavorited: false, languagesAvailable: "", name: "", numberOfViews: "", versions: [], versionsDescription: "")
    }
}
