//
//  ArticleAemImportDataParserError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ArticleAemImportDataParserError: Error {
    
    case failedToLocateJson(error: Error)
}
