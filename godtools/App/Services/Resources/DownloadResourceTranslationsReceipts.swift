//
//  DownloadResourceTranslationsReceipts.swift
//  godtools
//
//  Created by Levi Eggert on 7/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated)
class DownloadResourceTranslationsReceipts {
    
    typealias ResourceId = String
    
    private var receipts: [ResourceId: DownloadTranslationsReceipt] = Dictionary()
    
    required init() {
        
    }
    
    deinit {
        receipts.removeAll()
    }
    
    var isEmpty: Bool {
        return receipts.isEmpty
    }
    
    func addReceipt(resourceId: String, receipt: DownloadTranslationsReceipt) {
        receipts[resourceId] = receipt
    }
    
    func getReceipt(resourceId: String) -> DownloadTranslationsReceipt? {
        return receipts[resourceId]
    }
    
    func getReceipts() -> [ResourceId: DownloadTranslationsReceipt] {
        return receipts
    }
}
