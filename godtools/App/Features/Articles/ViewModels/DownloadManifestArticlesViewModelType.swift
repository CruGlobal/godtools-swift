//
//  DownloadManifestArticlesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DownloadManifestArticlesViewModelType: NSObject {
    
    var isLoading: ObservableValue<Bool> { get }
    var errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> { get }
    var downloadArticlesReceipt: ArticleManifestAemDownloadReceipt? { get set }
}

extension DownloadManifestArticlesViewModelType {
    
    func destroyDownloadArticlesReceipt() {
        
        downloadArticlesReceipt?.completed.removeObserver(self)
        
        let aemDownloaderReceipt = downloadArticlesReceipt?.aemDownloaderReceipt
        aemDownloaderReceipt?.removeAllObservers(object: self)
        aemDownloaderReceipt?.cancel()
        
        downloadArticlesReceipt = nil
    }
    
    func addReceiptObservers(manifestDownloadReceipt: ArticleManifestAemDownloadReceipt, manifest: ArticleManifestType, localizationServices: LocalizationServices) {
        
        let aemDownloaderReceipt: ArticleAemImportDownloaderReceipt = manifestDownloadReceipt.aemDownloaderReceipt
        
        aemDownloaderReceipt.started.addObserver(self) { [weak self] (started: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.accept(value: started)
            }
        }
        
        aemDownloaderReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemImportDownloaderResult) in
            
            DispatchQueue.main.async { [weak self] in
                    
                guard let viewModel = self else {
                    return
                }
                
                viewModel.isLoading.accept(value: false)
                
                if let error = result.downloadError, manifest.categories.isEmpty {
                        
                    let downloadArticlesErrorViewModel = DownloadArticlesErrorViewModel(
                        localizationServices: localizationServices,
                        error: error
                    )
                    
                    let errorViewModel = ArticlesErrorMessageViewModel(
                        localizationServices: localizationServices,
                        message: downloadArticlesErrorViewModel.message
                    )
                    
                    viewModel.errorMessage.accept(value: errorViewModel)
                }
            }
        }
        
        manifestDownloadReceipt.completed.addObserver(self) { [weak self] in
            
            self?.destroyDownloadArticlesReceipt()
        }
        
        downloadArticlesReceipt = manifestDownloadReceipt
    }
    
    func downloadArticles(downloader: ArticleManifestAemDownloader, manifest: ArticleManifestType, languageCode: String, localizationServices: LocalizationServices, forceDownload: Bool) -> ArticleManifestAemDownloadReceipt? {
            
        let downloadIsRunning: Bool = downloadArticlesReceipt != nil
        
        if downloadIsRunning {
            return nil
        }
              
        let manifestDownloadReceipt: ArticleManifestAemDownloadReceipt = downloader.downloadManifestAemUris(manifest: manifest, languageCode: languageCode)

        addReceiptObservers(
            manifestDownloadReceipt: manifestDownloadReceipt,
            manifest: manifest,
            localizationServices: localizationServices
        )
        
        return manifestDownloadReceipt
    }
}
