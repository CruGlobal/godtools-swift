//
//  DownloadableLanguageItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadableLanguageItemViewModel: ObservableObject {
    
    typealias LanguageId = String
    
    private static let endMarkedForRemovalAfterSeconds: TimeInterval = 3
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    private static var languageDownloaderObservers: [LanguageId: PublisherObserver<Double, Never>] = Dictionary()
    private static var markForRemovalObservers: [LanguageId: PublisherObserver<Date, Never>] = Dictionary()
        
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    
    @Published private(set) var downloadState: DownloadableLanguageDownloadState
    @Published private(set) var isMarkedForRemoval: Bool
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
        
        isMarkedForRemoval = Self.markForRemovalObservers[languageId] != nil
        
        if let downloadLanguageObserver = Self.languageDownloaderObservers[languageId] {
            
            if let progress = downloadLanguageObserver.currentValue {
                downloadState = .downloading(progress: progress)
            }
            else {
                downloadState = !downloadLanguageObserver.isRunning ? .downloaded : .notDownloaded
            }
            
            observeDownloadLanguage(
                publisherObserver: downloadLanguageObserver
            )
        }
        else {
            
            switch downloadableLanguage.downloadStatus {
                
            case .notDownloaded:
                downloadState = .notDownloaded
            case .downloaded( _):
                downloadState = .downloaded
            }
        }
        
        syncIconState()
        
        if let markForRemovalPublisherObserver = Self.markForRemovalObservers[languageId] {
            observeResetMarkedForRemoval(publisherObserver: markForRemovalPublisherObserver)
        }
    }
    
    private var languageId: String {
        return downloadableLanguage.languageId
    }
    
    private func syncIconState() {
        
        Publishers.CombineLatest(
            $downloadState,
            $isMarkedForRemoval
        )
        .flatMap { (downloadState: DownloadableLanguageDownloadState, isMarkedForRemoval: Bool) -> AnyPublisher<LanguageDownloadIconState, Never>  in
            
            let iconState: LanguageDownloadIconState
            
            if isMarkedForRemoval {
                iconState = .remove
            }
            else {
                
                switch downloadState {
                case .downloaded:
                    iconState = .downloaded
                case .downloading(let progress):
                    iconState = .downloading(progress: progress)
                case .failed:
                    iconState = .notDownloaded
                case .notDownloaded:
                    iconState = .notDownloaded
                }
            }
            
            return Just(iconState)
                .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$iconState)
    }
}

// MARK: - Download Language

extension DownloadableLanguageItemViewModel {
    
    private func downloadLanguage() {
        
        let publisherObserver: PublisherObserver<Double, Never> = PublisherObserver()
        
        observeDownloadLanguage(publisherObserver: publisherObserver)
        
        publisherObserver.start(
            publisher: downloadToolLanguageUseCase.downloadToolLanguage(languageId: languageId)
        )
        
        Self.languageDownloaderObservers[languageId] = publisherObserver
    }
    
    private func observeDownloadLanguage(publisherObserver: PublisherObserver<Double, Never>) {
        
        let languageId: String = self.languageId
        
        publisherObserver
            .observe { [weak self] (progress: Double) in
                
                self?.downloadState = .downloading(progress: progress)
                
            } onCompletion: { [weak self] _ in
                
                self?.downloadState = .downloaded
                Self.languageDownloaderObservers[languageId] = nil
            }
    }
    
    private func removeDownloadedLanguage() {
        
        removeDownloadedToolLanguageUseCase
            .removeDownloadedToolLanguage(languageId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                self?.downloadState = .notDownloaded
            }
            .store(in: &Self.backgroundCancellables)
    }
}

// MARK: - Mark For Removal Timer

extension DownloadableLanguageItemViewModel {
    
    private func startResetMarkedForRemovalTimer() {
                
        isMarkedForRemoval = true
        
        let publisherObserver: PublisherObserver<Date, Never> = PublisherObserver()
        
        Self.markForRemovalObservers[languageId] = publisherObserver
        
        observeResetMarkedForRemoval(publisherObserver: publisherObserver)
        
        let timer = Timer.publish(
            every: Self.endMarkedForRemovalAfterSeconds,
            on: .main,
            in: .common
        ).autoconnect()
        
        let timerPublisher = timer.eraseToAnyPublisher()

        publisherObserver.start(publisher: timerPublisher)
    }
    
    private func observeResetMarkedForRemoval(publisherObserver: PublisherObserver<Date, Never>) {

        publisherObserver
            .observe { [weak self] value in
                self?.stopResetMarkedForRemovalTimer()
            } onCompletion: { _ in
                
            }
    }
    
    private func stopResetMarkedForRemovalTimer() {
                        
        isMarkedForRemoval = false
        
        Self.markForRemovalObservers[languageId]?.cancel()
        Self.markForRemovalObservers[languageId] = nil
    }
    
    static func removeAllResetMarkedForRemovalTimers() {
        Self.markForRemovalObservers.removeAll()
    }
}

// MARK: - Inputs

extension DownloadableLanguageItemViewModel {
    
    func languageTapped() {
        
        switch downloadState {
            
        case .downloaded:
            
            if isMarkedForRemoval {
                
                stopResetMarkedForRemovalTimer()
                removeDownloadedLanguage()
            }
            else {
                
                startResetMarkedForRemovalTimer()
            }
            
        case .downloading( _):
            break
            
        case .failed:
            break
            
        case .notDownloaded:
            downloadLanguage()
        }
    }
}
