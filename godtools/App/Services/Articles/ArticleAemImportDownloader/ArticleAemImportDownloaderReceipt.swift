//
//  ArticleAemImportDownloaderReceipt.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemImportDownloaderReceipt {
    
    private var downloadAemImportsQueue: OperationQueue?
    
    private(set) var isCancelled: Bool = false
       
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: SignalValue<ArticleAemImportDownloaderResult> = SignalValue()
    
    required init() {

    }
    
    func startDownload(downloadAemImportsQueue: OperationQueue) {
        self.downloadAemImportsQueue = downloadAemImportsQueue
        started.accept(value: true)
    }
    
    func completeDownload(result: ArticleAemImportDownloaderResult) {
        completed.accept(value: result)
        reset()
    }
    
    func reset() {
        cancel()
        downloadAemImportsQueue = nil
        isCancelled = false
        started.accept(value: false)
    }
    
    func cancel() {
        isCancelled = true
        downloadAemImportsQueue?.cancelAllOperations()
        started.accept(value: false)
    }
    
    func removeAllObservers(object: NSObject) {
        started.removeObserver(object)
        completed.removeObserver(object)
    }
}
