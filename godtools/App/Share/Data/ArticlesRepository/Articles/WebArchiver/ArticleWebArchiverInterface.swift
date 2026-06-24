//
//  ArticleWebArchiverInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ArticleWebArchiverInterface: Sendable {
    
    func archive(webArchiveUrls: [WebArchiveUrl], requestPriority: RequestPriority) async -> ArticleWebArchiverArchive
}
