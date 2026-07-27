//
//  ArticleAemDownloaderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ArticleAemDownloaderInterface: Sendable {
    
    func download(
        aemUris: [String],
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority
    ) async -> [ArticleAemData]
}
