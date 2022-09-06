//
//  DownloadAttachmentsReceipt.swift
//  godtools
//
//  Created by Levi Eggert on 7/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated)
class DownloadAttachmentsReceipt {
    
    private let progress: ObservableValue<Double> = ObservableValue(value: 0)
    private let attachmentDownloaded: SignalValue<DownloadedAttachmentResult> = SignalValue()
    private let completed: Signal = Signal()
    
    private var queue: OperationQueue?
    
    private(set) var isRunning: Bool = false
        
    required init() {
        
    }
    
    var progressObserver: ObservableValue<Double> {
        return progress
    }
    
    var attachmentDownloadedSignal: SignalValue<DownloadedAttachmentResult> {
        return attachmentDownloaded
    }
    
    var completedSignal: Signal {
        return completed
    }
    
    func handleAttachmentDownloaded(result: DownloadedAttachmentResult) {
        attachmentDownloaded.accept(value: result)
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
