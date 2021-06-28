//
//  ParsedDeepLinkType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum ParsedDeepLinkType {
    
    case allToolsList
    case article(articleURI: String)
    case favoritedToolsList
    case lessonsList
    case tool(resourceAbbreviation: String, primaryLanguageCodes: [String], parallelLanguageCodes: [String], liveShareStream: String?, page: Int?)
}
