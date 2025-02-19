//
//  DownloadableLanguagesDownloadHandler.swift
//  godtools
//
//  Created by Rachael Skeath on 2/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol DownloadableLanguagesDownloadHandlerDelegate: AnyObject {
    
    func downloadableLanguagesDownloadHandlerCompleted(handler: DownloadableLanguagesDownloadHandler, error: Error?)
    func downloadableLanguagesDownloadHandlerProgressChanged(handler: DownloadableLanguagesDownloadHandler, progress: Double)
}

class DownloadableLanguagesDownloadHandler {
         
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    
    private var downloadCancellable: AnyCancellable?
    
    private(set) var downloadFinished: Bool = false
    private(set) var downloadError: Error?
    private(set) var downloadProgress: Double?
    
    private weak var delegate: DownloadableLanguagesDownloadHandlerDelegate?
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    
    init(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, downloadableLanguage: DownloadableLanguageListItemDomainModel) {
        
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.downloadableLanguage = downloadableLanguage
    }
    
    var isDownloading: Bool {
        return downloadCancellable != nil
    }
    
    func setDelegate(_ delegate: DownloadableLanguagesDownloadHandlerDelegate?) {
        self.delegate = delegate
    }
    
    func startDownload(delegate: DownloadableLanguagesDownloadHandlerDelegate) {
                        
        self.delegate = delegate
        
        downloadCancellable = downloadToolLanguageUseCase.downloadToolLanguage(languageId: downloadableLanguage.languageId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in

                self?.downloadFinished = true
                self?.downloadProgress = nil
                
                let downloadError: Error?
                
                switch completed {
                case .finished:
                    downloadError = nil
                    
                case .failure(let error):
                    self?.downloadError = error
                    downloadError = error
                }
                
                if let handler = self {
                    
                    self?.delegate?.downloadableLanguagesDownloadHandlerCompleted(
                        handler: handler,
                        error: downloadError
                    )
                }

            }, receiveValue: { [weak self] (progress: Double) in
                
                self?.downloadProgress = progress
                
                if let handler = self {
                    
                    self?.delegate?.downloadableLanguagesDownloadHandlerProgressChanged(
                        handler: handler,
                        progress: progress
                    )
                }
            })
    }
    
    func cancelDownload() {
        
        downloadCancellable?.cancel()
        downloadCancellable = nil
        downloadFinished = false
        downloadError = nil
        downloadProgress = nil
    }
}
