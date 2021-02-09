//
//  ParsedDeepLinkType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum ParsedDeepLinkType {
    
    case tool(resourceAbbreviation: String, primaryLanguageCodes: [String], parallelLanguageCodes: [String], liveShareStream: String?, page: Int?)
    case article(resourceAbbreviation: String, translationZipFile: TranslationZipFileModel, articleAemImportData: ArticleAemImportData)
}
