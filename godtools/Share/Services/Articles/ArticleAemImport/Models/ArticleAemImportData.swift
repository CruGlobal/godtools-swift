//
//  ArticleAemImportData.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemImportData: ArticleAemImportDataType {
    
    let articleJcrContent: ArticleJcrContent?
    let languageCode: String
    let resourceId: String
    let webUrl: String
    let webArchiveFilename: String
}
