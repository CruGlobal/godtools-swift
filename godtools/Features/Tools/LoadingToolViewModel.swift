//
//  LoadingToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LoadingToolViewModel: NSObject, LoadingToolViewModelType {
    
    private let resource: ResourceModel
    private let preferredTranslation: PreferredLanguageTranslationResult
    private let translationDownloader: TranslationDownloader
    private let completeHandler: CallbackValueHandler<Result<TranslationManifest, TranslationDownloaderError>>
    private let closeHandler: CallbackHandler
    private let fakeDownloadProgressInterval: TimeInterval = 1 / 60
    private let fakeDownloadProgressTotalTimeSeconds: TimeInterval = 3
    
    private var fakeDownloadProgressTimer: Timer?
    private var downloadTranslationOperation: OperationQueue?
    private var downloadTranslationResult: Result<TranslationManifest, TranslationDownloaderError>?
        
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let downloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let alertMessage: ObservableValue<AlertMessageType?> = ObservableValue(value: nil)
    
    required init(resource: ResourceModel, preferredTranslation: PreferredLanguageTranslationResult, translationDownloader: TranslationDownloader, completeHandler: CallbackValueHandler<Result<TranslationManifest, TranslationDownloaderError>>, closeHandler: CallbackHandler) {

        self.resource = resource
        self.preferredTranslation = preferredTranslation
        self.translationDownloader = translationDownloader
        self.completeHandler = completeHandler
        self.closeHandler = closeHandler

        super.init()

        downloadTranslation()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        stopFakeDownloadProgressTimer()
        cancelDownloadTranslation()
    }
    
    private func cancelDownloadTranslation() {
        downloadTranslationOperation?.cancelAllOperations()
    }
    
    private func downloadTranslation() {
        
        let translationId: String = preferredTranslation.preferredLanguageTranslation?.id ?? ""
        
        guard !translationId.isEmpty else {
            alertMessage.accept(value: AlertMessage(title: "Error", message: "Translation does not exist."))
            return
        }
        
        isLoading.accept(value: true)
                
        fakeDownloadProgressTimer = Timer.scheduledTimer(
            timeInterval: fakeDownloadProgressInterval,
            target: self,
            selector: #selector(handleFakeDownloadProgressTimer),
            userInfo: nil,
            repeats: true
        )
        
        downloadTranslationOperation = translationDownloader.downloadTranslation(translationId: translationId, complete: { [weak self] (result: Result<TranslationManifest, TranslationDownloaderError>) in
            
            DispatchQueue.main.async { [weak self] in
            
                self?.downloadTranslationResult = result
                
                self?.handleProgressTimerAndDownloadRequestCompleted()
            }
        })
    }
    
    @objc func handleFakeDownloadProgressTimer() {
        
        let currentProgress: Double = downloadProgress.value
        let progress: Double = currentProgress + (fakeDownloadProgressInterval * (1 / fakeDownloadProgressTotalTimeSeconds))
                
        if progress >= 0.98 {
            stopFakeDownloadProgressTimer()
        }
        
        downloadProgress.accept(value: progress)
        
        handleProgressTimerAndDownloadRequestCompleted()
    }
    
    private func handleProgressTimerAndDownloadRequestCompleted() {
                
        if fakeDownloadProgressTimer == nil, let downloadTranslationResult = self.downloadTranslationResult {
            
            isLoading.accept(value: false)
            downloadProgress.accept(value: 1)
            
            completeHandler.handle(downloadTranslationResult)
        }
    }
    
    private func stopFakeDownloadProgressTimer() {
        fakeDownloadProgressTimer?.invalidate()
        fakeDownloadProgressTimer = nil
    }
    
    func closeTapped() {
        stopFakeDownloadProgressTimer()
        cancelDownloadTranslation()
        closeHandler.handle()
    }
}
