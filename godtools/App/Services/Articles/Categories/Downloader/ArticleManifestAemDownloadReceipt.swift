//
//  ArticleManifestAemDownloadReceipt.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleManifestAemDownloadReceipt {
    
    let aemDownloaderReceipt: ArticleAemImportDownloaderReceipt
    let completed: Signal = Signal()
    
    required init(aemDownloaderReceipt: ArticleAemImportDownloaderReceipt) {
        
        self.aemDownloaderReceipt = aemDownloaderReceipt
    }
}
