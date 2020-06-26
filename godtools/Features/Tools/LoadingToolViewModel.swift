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
    private let translationDownloader: TranslationDownloader
    private let completeHandler: CallbackValueHandler<[DownloadedTranslationResult]>
    private let closeHandler: CallbackHandler
    private let fakeDownloadProgressInterval: TimeInterval = 1 / 60
    private let fakeDownloadProgressTotalTimeSeconds: TimeInterval = 3
    private let progressNumberFormatter: NumberFormatter = NumberFormatter()
    
    private var fakeDownloadProgressTimer: Timer?
    private var downloadTranslationsReceipt: DownloadTranslationsReceipt?
    private var downloadedTranslations: [DownloadedTranslationResult] = Array()
    private var downloadCompleted: Bool = false
    private var downloadCancelled: Bool = false
        
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let downloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let progressValue: ObservableValue<String> = ObservableValue(value: "0%")
    let alertMessage: ObservableValue<AlertMessageType?> = ObservableValue(value: nil)
    
    required init(resource: ResourceModel, translationsToDownload: [TranslationModel], translationDownloader: TranslationDownloader, completeHandler: CallbackValueHandler<[DownloadedTranslationResult]>, closeHandler: CallbackHandler) {

        self.resource = resource
        self.translationDownloader = translationDownloader
        self.completeHandler = completeHandler
        self.closeHandler = closeHandler

        super.init()
        
        progressNumberFormatter.alwaysShowsDecimalSeparator = false
        progressNumberFormatter.numberStyle = .none

        setProgress(progress: 0)
        
        downloadTranslations(translations: translationsToDownload)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        stopFakeDownloadProgressTimer()
        destroyDownloadTranslationsReceipt()
    }
    
    private func destroyDownloadTranslationsReceipt() {
        if let receipt = downloadTranslationsReceipt {
            receipt.translationDownloaded.removeObserver(self)
            receipt.progress.removeObserver(self)
            receipt.completed.removeObserver(self)
            receipt.cancel()
            downloadTranslationsReceipt = nil
        }
    }
    
    private func stopFakeDownloadProgressTimer() {
        fakeDownloadProgressTimer?.invalidate()
        fakeDownloadProgressTimer = nil
    }
    
    private func downloadTranslations(translations: [TranslationModel]) {
                               
        isLoading.accept(value: true)
                
        fakeDownloadProgressTimer = Timer.scheduledTimer(
            timeInterval: fakeDownloadProgressInterval,
            target: self,
            selector: #selector(handleFakeDownloadProgressTimer),
            userInfo: nil,
            repeats: true
        )
        
        let translationIds: [String] = translations.map({$0.id})
        let downloadReceipt: DownloadTranslationsReceipt? = translationDownloader.downloadTranslations(translationIds: translationIds)
        
        guard let receipt = downloadReceipt else {
            handleProgressTimerAndDownloadRequestCompleted()
            return
        }
        
        receipt.translationDownloaded.addObserver(self) { (downloadResult: DownloadedTranslationResult) in
            DispatchQueue.main.async { [weak self] in
                self?.downloadedTranslations.append(downloadResult)
            }
        }
        
        receipt.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.downloadCompleted = true
                self?.handleProgressTimerAndDownloadRequestCompleted()
            }
        }
        
        self.downloadTranslationsReceipt = receipt
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
    
    private func setProgress(progress: Double) {
        downloadProgress.accept(value: progress)
        
        let formattedProgress: String = progressNumberFormatter.string(from: NSNumber(value: progress * 100)) ?? "0"
        progressValue.accept(value: formattedProgress + "%")
    }
    
    private var progressTimerAndTranslationDownloadCompleted: Bool {
        return fakeDownloadProgressTimer == nil && downloadCompleted
    }
    
    private func handleProgressTimerAndDownloadRequestCompleted() {
                
        if progressTimerAndTranslationDownloadCompleted && !downloadCancelled {
            
            isLoading.accept(value: false)
            setProgress(progress: 1)
            
            completeHandler.handle(downloadedTranslations)
        }
    }

    func closeTapped() {
        downloadCancelled = true
        stopFakeDownloadProgressTimer()
        destroyDownloadTranslationsReceipt()
        closeHandler.handle()
    }
}
