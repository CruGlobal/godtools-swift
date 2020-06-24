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
    private let completeHandler: CallbackValueHandler<Result<TranslationManifestData, TranslationDownloaderError>>
    private let closeHandler: CallbackHandler
    private let fakeDownloadProgressInterval: TimeInterval = 1 / 60
    private let fakeDownloadProgressTotalTimeSeconds: TimeInterval = 3
    private let progressNumberFormatter: NumberFormatter = NumberFormatter()
    
    private var fakeDownloadProgressTimer: Timer?
    private var downloadTranslationOperation: OperationQueue?
    private var downloadTranslationResult: Result<TranslationManifestData, TranslationDownloaderError>?
        
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let downloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let progressValue: ObservableValue<String> = ObservableValue(value: "0%")
    let alertMessage: ObservableValue<AlertMessageType?> = ObservableValue(value: nil)
    
    required init(resource: ResourceModel, preferredTranslation: PreferredLanguageTranslationResult, translationDownloader: TranslationDownloader, completeHandler: CallbackValueHandler<Result<TranslationManifestData, TranslationDownloaderError>>, closeHandler: CallbackHandler) {

        self.resource = resource
        self.preferredTranslation = preferredTranslation
        self.translationDownloader = translationDownloader
        self.completeHandler = completeHandler
        self.closeHandler = closeHandler

        super.init()
        
        progressNumberFormatter.alwaysShowsDecimalSeparator = false
        progressNumberFormatter.numberStyle = .none

        setProgress(progress: 0)
        
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
        
        downloadTranslationOperation = translationDownloader.downloadTranslation(translationId: translationId, complete: { [weak self] (result: Result<TranslationManifestData, TranslationDownloaderError>) in
            
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
        
        setProgress(progress: progress)
        
        handleProgressTimerAndDownloadRequestCompleted()
    }
    
    private func handleProgressTimerAndDownloadRequestCompleted() {
                
        if fakeDownloadProgressTimer == nil, let downloadTranslationResult = self.downloadTranslationResult {
            
            isLoading.accept(value: false)
            setProgress(progress: 1)
            
            completeHandler.handle(downloadTranslationResult)
        }
    }
    
    private func setProgress(progress: Double) {
        downloadProgress.accept(value: progress)
        
        let formattedProgress: String = progressNumberFormatter.string(from: NSNumber(value: progress * 100)) ?? "0"
        progressValue.accept(value: formattedProgress + "%")
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
