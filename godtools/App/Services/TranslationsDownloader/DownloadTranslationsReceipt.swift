//
//  DownloadTranslationsReceipts.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // This should be removed in place of TranslationsRepository following GT-1448. ~Levi
class DownloadTranslationsReceipt {
    
    private let translationIds: [String]
    private let progress: ObservableValue<Double> = ObservableValue(value: 0)
    private let translationDownloaded: SignalValue<DownloadedTranslationResult> = SignalValue()
    private let completed: Signal = Signal()
    
    private var queue: OperationQueue?
    
    private(set) var isRunning: Bool = false
    
    required init(translationIds: [String]) {
        
        self.translationIds = translationIds
    }
    
    var progressObserver: ObservableValue<Double> {
        return progress
    }
    
    var translationDownloadedSignal: SignalValue<DownloadedTranslationResult> {
        return translationDownloaded
    }
    
    var completedSignal: Signal {
        return completed
    }
    
    func handleTranslationDownloaded(result: DownloadedTranslationResult) {
        translationDownloaded.accept(value: result)
    }
    
    func setProgress(value: Double) {
        if isRunning {
            progress.accept(value: value)
        }
    }
    
    func cancel() {
        queue?.cancelAllOperations()
        complete()
    }
    
    func start(queue: OperationQueue) {
        self.queue = queue
        isRunning = true
        setProgress(value: 0)
    }
    
    func complete() {
        setProgress(value: 1)
        isRunning = false
        completed.accept()
        progress.setValue(value: 0)
    }
}
