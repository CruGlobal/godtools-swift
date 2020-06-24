//
//  DownloadTranslationsReceipts.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DownloadTranslationsReceipt {
    
    let translationIds: [String]
    let queue: OperationQueue
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let translationDownloaded: SignalValue<Result<TranslationManifestData, TranslationDownloaderError>> = SignalValue()
    
    required init(translationIds: [String], queue: OperationQueue) {
        
        self.translationIds = translationIds
        self.queue = queue
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
}
