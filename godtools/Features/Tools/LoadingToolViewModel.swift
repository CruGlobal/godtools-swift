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
    private let resourcesService: ResourcesService
    private let translationDownloader: TranslationDownloader
    private let completeHandler: CallbackValueHandler<Result<TranslationManifest, TranslationDownloaderError>>
    private let fakeDownloadProgressInterval: TimeInterval = 1 / 60
    
    private var fakeDownloadProgressTimer: Timer?
    private var downloadTranslationOperation: OperationQueue?
        
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let downloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let alertMessage: ObservableValue<AlertMessageType?> = ObservableValue(value: nil)
    
    required init(resource: ResourceModel, preferredTranslation: PreferredLanguageTranslationResult, resourcesService: ResourcesService, translationDownloader: TranslationDownloader, completeHandler: CallbackValueHandler<Result<TranslationManifest, TranslationDownloaderError>>) {

        self.resource = resource
        self.preferredTranslation = preferredTranslation
        self.resourcesService = resourcesService
        self.translationDownloader = translationDownloader
        self.completeHandler = completeHandler

        super.init()

        downloadTranslation()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        stopFakeDownloadProgressTimer()
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
                
                self?.isLoading.accept(value: false)
                self?.stopFakeDownloadProgressTimer()
                self?.downloadProgress.accept(value: 1)
                
                self?.completeHandler.handle(result)
            }
        })
    }
    
    @objc func handleFakeDownloadProgressTimer() {
        
        let currentProgress: Double = downloadProgress.value
        let progressThrottle: Double = currentProgress >= 0.8 ? 0.15 : 0.3
        let progress: Double = currentProgress + (fakeDownloadProgressInterval * progressThrottle)
                
        if progress >= 0.98 {
            stopFakeDownloadProgressTimer()
        }
        
        downloadProgress.accept(value: progress)
    }
    
    private func stopFakeDownloadProgressTimer() {
        fakeDownloadProgressTimer?.invalidate()
        fakeDownloadProgressTimer = nil
    }
}
