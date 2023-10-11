//
//  ToolDetailsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolDetailsDomainModel {
    
    let aboutDescription: String
    let bibleReferences: String
    let conversationStarters: String
    let languagesAvailable: String
    let name: String
    let numberOfViews: String
    let versions: [ToolVersionDomainModel]
    let versionsDescription: String
}
