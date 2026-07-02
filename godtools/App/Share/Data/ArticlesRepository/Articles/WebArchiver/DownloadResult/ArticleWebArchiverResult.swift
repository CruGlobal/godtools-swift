//
//  ArticleWebArchiverResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleWebArchiverResult: Sendable {
    
    let archive: ArticleWebArchiveData?
    let error: Error?
}
