//
//  ToolDeepLink.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ToolDeepLink {
    
    let resourceAbbreviation: String
    let primaryLanguageCodes: [String]
    let parallelLanguageCodes: [String]
    let liveShareStream: String?
    let page: Int?
    let pageId: String?
}
