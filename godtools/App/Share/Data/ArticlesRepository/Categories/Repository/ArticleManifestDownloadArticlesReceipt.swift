//
//  ArticleManifestDownloadArticlesReceipt.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleManifestDownloadArticlesReceipt {
    
    private var downloadQueue: OperationQueue?
    
    private(set) var isCancelled: Bool = false
    
    let isRunning: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<ArticleAemRepositoryResult?> = ObservableValue(value: nil)
    
    init() {
        
    }
    
    func downloadStarted(downloadQueue: OperationQueue) {
        self.downloadQueue = downloadQueue
        isRunning.accept(value: true)
    }
    
    func downloadCompleted(result: ArticleAemRepositoryResult) {
        completed.accept(value: result)
        reset()
    }
    
    func reset() {
        cancel()
        downloadQueue = nil
        isCancelled = false
        isRunning.accept(value: false)
    }
    
    func cancel() {
        isCancelled = true
        downloadQueue?.cancelAllOperations()
        isRunning.accept(value: false)
    }
    
    func removeAllObserversFrom(object: NSObject) {
        isRunning.removeObserver(object)
        completed.removeObserver(object)
    }
}
