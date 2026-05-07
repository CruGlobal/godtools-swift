//
//  AemUriDownloadResult.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct AemUriDownloadResult: Sendable {
    
    let articleAemData: ArticleAemData?
    let downloadError: ArticleAemDownloadOperationError?
}
