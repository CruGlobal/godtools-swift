//
//  DownloadableLanguagesDownloadHandler.swift
//  godtools
//
//  Created by Rachael Skeath on 2/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadableLanguagesDownloadHandler {
    
    private let activeDownloadsObserver = CurrentValueSubject<[BCP47LanguageIdentifier: LanguageDownloadStatusDomainModel], Never>([:])
    
    private weak var delegate: DownloadableLanguagesDownloadHandlerDelegate?
    private var downloadPublishers: [String: AnyPublisher<Double, Error>] = [:]
    private var backgroundDownloadCancellables = Set<AnyCancellable>()

    // MARK: - Inputs
    
    func setDelegate(_ delegate: DownloadableLanguagesDownloadHandlerDelegate) {
        self.delegate = delegate
    }
    
    func removeDelegate() {
        self.delegate = nil
    }
    
    func getActiveDownloadsObserver() -> AnyPublisher<[BCP47LanguageIdentifier: LanguageDownloadStatusDomainModel], Never> {
        return activeDownloadsObserver.eraseToAnyPublisher()
    }
    
    func downloadLanguage(_ downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase) {
        
        let languageId = downloadableLanguage.languageId
        activeDownloadsObserver.value[languageId] = .downloading(progress: 0)
        
        let downloadPublisher = downloadToolLanguageUseCase.downloadToolLanguage(languageId: languageId, languageCode: downloadableLanguage.languageCode)
        
        downloadPublishers[languageId] = downloadPublisher
        
         downloadPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in
                
                switch completed {
                case .finished:

                    self?.activeDownloadsObserver.value.removeValue(forKey: languageId)
                    self?.downloadPublishers.removeValue(forKey: languageId)
                    
                    self?.delegate?.downloadComplete(languageId: languageId)
                    
                case .failure(let error):
                    
                    self?.activeDownloadsObserver.value[languageId] = .notDownloaded
                    self?.delegate?.downloadFailure(languageId: languageId, error: error)
                }
            }, receiveValue: { [weak self] progress in
                
                self?.activeDownloadsObserver.value[languageId] = .downloading(progress: progress)
                self?.delegate?.downloadProgressUpdate(languageId: languageId, progress: progress)

            })
            .store(in: &backgroundDownloadCancellables)
    }
}
