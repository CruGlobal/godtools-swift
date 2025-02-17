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
    
    func handlerDownloadComplete(handler: DownloadableLanguagesDownloadHandler, error: Error?)
    func handlerDownloadProgressUpdate(handler: DownloadableLanguagesDownloadHandler, progress: Double)
}

class DownloadableLanguagesDownloadHandler {
         
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var downloadFinished: Bool?
    private(set) var downloadError: Error?
    private(set) var downloadProgress: Double?
    private(set) var isDownloading: Bool = false
    
    private weak var delegate: DownloadableLanguagesDownloadHandlerDelegate?
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    
    init(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, downloadableLanguage: DownloadableLanguageListItemDomainModel) {
        
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.downloadableLanguage = downloadableLanguage
    }
    
    func setDelegate(_ delegate: DownloadableLanguagesDownloadHandlerDelegate?) {
        self.delegate = delegate
    }
    
    func downloadLanguage(delegate: DownloadableLanguagesDownloadHandlerDelegate) {
                
        isDownloading = true
        
        self.delegate = delegate
        
        downloadToolLanguageUseCase.downloadToolLanguage(languageId: downloadableLanguage.languageId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in

                self?.isDownloading = false
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
                    
                    delegate.handlerDownloadComplete(
                        handler: handler,
                        error: downloadError
                    )
                }

            }, receiveValue: { [weak self] (progress: Double) in
                
                self?.downloadProgress = progress
                
                if let handler = self {
                    
                    delegate.handlerDownloadProgressUpdate(
                        handler: handler,
                        progress: progress
                    )
                }
            })
            .store(in: &cancellables)
    }
}
