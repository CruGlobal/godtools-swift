//
//  DownloadToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DownloadToolViewModel: NSObject, DownloadToolViewModelType {
    
    private let initialDataDownloader: InitialDataDownloader
    private let translationDownloader: TranslationDownloader
    private let determineTranslationsToDownload: DetermineToolTranslationsToDownloadType
    private let resourcesCache: ResourcesCache
    private let translationsFileCache: TranslationsFileCache
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let localizationServices: LocalizationServices
    private let didDownloadToolClosure: ((_ result: Result<DownloadedToolData, DownloadToolError>) -> Void)
    private let didCloseClosure: (() -> Void)
    private let downloadProgressNumberFormatter: NumberFormatter = NumberFormatter()
    private let downloadProgressIntervalRatePerSecond: TimeInterval = 60
    
    private var downloadTranslationsReceipt: DownloadTranslationsReceipt?
    private var downloadedToolResult: Result<DownloadedToolData, DownloadToolError>?
    private var downloadProgressTimer: Timer?
    private var downloadProgressTimerIntervalCount: TimeInterval = 0
    private var didStartToolDownload: Bool = false
    
    let message: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let downloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let progressValue: ObservableValue<String> = ObservableValue(value: "")
    
    required init(initialDataDownloader: InitialDataDownloader, translationDownloader: TranslationDownloader, determineTranslationsToDownload: DetermineToolTranslationsToDownloadType, resourcesCache: ResourcesCache, translationsFileCache: TranslationsFileCache, favoritedResourcesCache: FavoritedResourcesCache, localizationServices: LocalizationServices, didDownloadToolClosure: @escaping ((_ result: Result<DownloadedToolData, DownloadToolError>) -> Void), didCloseClosure: @escaping (() -> Void)) {
        
        self.initialDataDownloader = initialDataDownloader
        self.translationDownloader = translationDownloader
        self.determineTranslationsToDownload = determineTranslationsToDownload
        self.resourcesCache = resourcesCache
        self.translationsFileCache = translationsFileCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.localizationServices = localizationServices
        self.didDownloadToolClosure = didDownloadToolClosure
        self.didCloseClosure = didCloseClosure
        
        super.init()
        
        setDownloadProgress(progress: 0)
        
        reloadDownloaderMessage()
    }
    
    deinit {

        stopDownload()
    }
    
    func pageDidAppear() {
        
        startToolDownload()
    }
    
    func closeTapped() {
        
        stopDownload()
        
        didCloseClosure()
    }
    
    private func removeInitialDataDownloaderObservers() {
        
        initialDataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        initialDataDownloader.didDownloadAndCacheResources.removeObserver(self)
    }
    
    private func startToolDownload() {
        
        guard !didStartToolDownload else {
            return
        }
        
        didStartToolDownload = true
        
        startDownloadProgressTimer()
        
        initialDataDownloader.didDownloadAndCacheResources.addObserver(self) { [weak self] (didDownloadAndCacheResources: Bool) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                
                if didDownloadAndCacheResources {
                    weakSelf.removeInitialDataDownloaderObservers()
                    weakSelf.getToolLanguageTranslationManifestsFromCacheElseDownloadFromRemote()
                }
            }
        }
    }
    
    private func stopDownload() {
        
        stopDownloadProgressTimer()
        removeInitialDataDownloaderObservers()
        destroyDownloadTranslationsReceipt()
    }
    
    // MARK: - Message
    
    private func reloadDownloaderMessage() {
        
        let messageValue: String
        
        let resource: ResourceModel? = determineTranslationsToDownload.getResource()
        let resourceType: ResourceType? = resource?.resourceTypeEnum
        
        if resourceType == .article || resourceType == .tract, let resourceId = resource?.id {
            
            let isFavoritedResource: Bool = favoritedResourcesCache.isFavorited(resourceId: resourceId)
            
            messageValue = isFavoritedResource ? localizationServices.stringForMainBundle(key: "loading_favorited_tool") : localizationServices.stringForMainBundle(key: "loading_unfavorited_tool")
        }
        else if resourceType == .lesson {
            
            messageValue = localizationServices.stringForMainBundle(key: "loading_favorited_tool")
        }
        else {
            
            messageValue = localizationServices.stringForMainBundle(key: "loading_favorited_tool")
        }
        
        message.accept(value: messageValue)
    }
        
    // MARK: - Download Progress
    
    private var downloadProgressInterval: TimeInterval {
        return 1 / downloadProgressIntervalRatePerSecond
    }
    
    private func startDownloadProgressTimer() {
        
        guard downloadProgressTimer == nil else {
            return
        }
        
        downloadProgressTimer = Timer.scheduledTimer(
            timeInterval: downloadProgressInterval,
            target: self,
            selector: #selector(handleDownloadProgressTimerInterval),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func stopDownloadProgressTimer() {
        downloadProgressTimer?.invalidate()
        downloadProgressTimer = nil
    }
    
    @objc private func handleDownloadProgressTimerInterval() {
               
        downloadProgressTimerIntervalCount += 1
        
        let didCompleteToolDownload: Bool = self.downloadedToolResult != nil
        //let didDisplayDownloaderForMinimumSeconds: Bool = downloadProgressTimerIntervalCount >= (downloaderMinimumDisplaySeconds * downloadProgressIntervalRatePerSecond)

        let slowDownloadProgress: Double = downloadProgressInterval / 10
        let fastDownloadProgress: Double = downloadProgressInterval / 1
                
        let currentDownloadProgress: Double = downloadProgress.value
        let downloadProgressSpeed: Double = didCompleteToolDownload ? fastDownloadProgress : slowDownloadProgress
        
        var newDownloadProgress: Double = (currentDownloadProgress + downloadProgressSpeed) * 100
        
        if let downloadedToolResult = self.downloadedToolResult {
            
            switch downloadedToolResult {
            
            case .success(let downloadedToolData):
                
                if newDownloadProgress >= 99 {
                    
                    stopDownload()
                    setDownloadProgress(progress: 1)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        
                        self?.didDownloadToolClosure(.success(downloadedToolData))
                    }
                    
                    return
                }
                
            case .failure(let downloadToolError):
                
                stopDownload()
                didDownloadToolClosure(.failure(downloadToolError))
                
                return
            }
        }
        
        if newDownloadProgress > 99 {
            newDownloadProgress = 99
        }
        
        setDownloadProgress(progress: newDownloadProgress / 100)
    }
    
    private func setDownloadProgress(progress: Double) {
        
        downloadProgressNumberFormatter.alwaysShowsDecimalSeparator = false
        downloadProgressNumberFormatter.numberStyle = .none
        
        downloadProgress.accept(value: progress)
        
        let formattedProgress: String = downloadProgressNumberFormatter.string(from: NSNumber(value: progress * 100)) ?? "0"
        progressValue.accept(value: formattedProgress + "%")
    }
    
    // MARK: - Get Tool Language Translation Manifests
    
    private func getToolLanguageTranslationManifestsFromCacheElseDownloadFromRemote() {
        
        let translationManifestsToDownloadResult: Result<DownloadToolLanguageTranslations, DetermineToolTranslationsToDownloadError> = determineTranslationsToDownload.determineToolTranslationsToDownload()
        
        switch translationManifestsToDownloadResult {
            
        case .success(let toolLanguageTranslations):
            
            let getToolTranslations = GetToolTranslationsFromCache(
                dataDownloader: initialDataDownloader,
                resourcesCache: resourcesCache,
                translationsFileCache: translationsFileCache
            )
            
            let getToolTranslationsCacheResult: GetToolTranslationsFromCacheResult = getToolTranslations.getTranslations(
                resource: toolLanguageTranslations.resource,
                languages: toolLanguageTranslations.languages
            )
            
            guard getToolTranslationsCacheResult.translationIdsNeededDownloading.isEmpty else {
                downloadTranslationManifestsFromRemoteDatabase(translationIds: getToolTranslationsCacheResult.translationIdsNeededDownloading)
                return
            }
            
            let toolData = DownloadedToolData(resource: toolLanguageTranslations.resource, languageTranslations: getToolTranslationsCacheResult.toolTranslations)
            
            downloadedToolResult = .success(toolData)
                        
        case .failure(let determineToolTranslationsToDownloadError):
            
            downloadedToolResult = .failure(.failedToDetermineToolTranslationsToDownload(determineToolTranslationsToDownloadError: determineToolTranslationsToDownloadError))
        }
    }
    
    private func destroyDownloadTranslationsReceipt() {
        
        guard let downloadTranslationsReceipt = self.downloadTranslationsReceipt else {
            return
        }
        
        downloadTranslationsReceipt.progressObserver.removeObserver(self)
        downloadTranslationsReceipt.translationDownloadedSignal.removeObserver(self)
        downloadTranslationsReceipt.completedSignal.removeObserver(self)
        downloadTranslationsReceipt.cancel()
        
        self.downloadTranslationsReceipt = nil
    }
    
    private func downloadTranslationManifestsFromRemoteDatabase(translationIds: [String]) {
                                
        var translationDownloaderErrors: [TranslationDownloaderError] = Array()
       
        destroyDownloadTranslationsReceipt()
        
        downloadTranslationsReceipt = translationDownloader.downloadAndCacheTranslationManifests(translationIds: translationIds)
        
        downloadTranslationsReceipt?.translationDownloadedSignal.addObserver(self, onObserve: { (downloadedTranslationResult: DownloadedTranslationResult) in
            
            if let downloadTranslationError = downloadedTranslationResult.downloadError {
                translationDownloaderErrors.append(downloadTranslationError)
            }
        })
        
        downloadTranslationsReceipt?.completedSignal.addObserver(self, onObserve: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.downloadTranslationsReceipt?.translationDownloadedSignal.removeObserver(weakSelf)
                weakSelf.downloadTranslationsReceipt?.completedSignal.removeObserver(weakSelf)
                
                if translationDownloaderErrors.isEmpty {
                    weakSelf.getToolLanguageTranslationManifestsFromCacheElseDownloadFromRemote()
                }
                else {
                    weakSelf.downloadedToolResult = .failure(.failedToDownloadTranslations(translationDownloaderErrors: translationDownloaderErrors))
                }
            }
        })
    }
}
