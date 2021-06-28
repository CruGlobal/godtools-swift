//
//  ParsedDeepLinkType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum ParsedDeepLinkType {
    
    case article(articleURI: String)
    case lessonsList
    case tool(resourceAbbreviation: String, primaryLanguageCodes: [String], parallelLanguageCodes: [String], liveShareStream: String?, page: Int?)
}
