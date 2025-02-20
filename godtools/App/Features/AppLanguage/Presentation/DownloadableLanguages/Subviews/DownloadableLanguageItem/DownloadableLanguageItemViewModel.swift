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
    
    private static var languageDownloaderObservers: [LanguageId: CurrentValueSubject<Double, Never>] = Dictionary()
    private static var markedForRemovalTimerObservers: [LanguageId: PassthroughSubject<Void, Never>] = Dictionary()
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    
    @Published private(set) var downloadState: DownloadableLanguageDownloadState
    @Published private(set) var isMarkedForRemoval: Bool
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
        
        isMarkedForRemoval = Self.markedForRemovalTimerObservers[languageId] != nil
        
        if let currentDownloadProgress = Self.languageDownloaderObservers[languageId]?.value {
            
            downloadState = .downloading(progress: currentDownloadProgress)
        }
        else {
            
            switch downloadableLanguage.downloadStatus {
                
            case .notDownloaded:
                downloadState = .notDownloaded
            case .downloaded( _):
                downloadState = .downloaded
            }
        }
        
        bindIconState()
        observeLanguageDownload()
        observeResetMarkedForRemovalTimer()
    }
    
    private var languageId: String {
        return downloadableLanguage.languageId
    }
    
    private func bindIconState() {
        
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

// MARK: - Remove Downloaded Language

extension DownloadableLanguageItemViewModel {
    
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

// MARK: - Download Language

extension DownloadableLanguageItemViewModel {
    
    private static func isDownloadingLanguage(languageId: String) -> Bool {
        return Self.languageDownloaderObservers[languageId] != nil
    }
    
    private func observeLanguageDownload() {
        
        guard let currentValueSubject = Self.languageDownloaderObservers[languageId] else {
            return
        }
        
        let languageId: String = self.languageId
        
        currentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (progress: Double) in
                
                if progress < 1 {
                    self?.downloadState = .downloading(progress: progress)
                }
                else {
                    self?.downloadState = .downloaded
                    Self.removeLanguageDownloadObserver(languageId: languageId)
                }
            }
            .store(in: &cancellables)
    }
    
    private static func downloadLanguageInBackground(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, languageId: String) {
           
        Self.languageDownloaderObservers[languageId] = CurrentValueSubject(0)
        
        downloadToolLanguageUseCase
            .downloadToolLanguage(languageId: languageId)
            .sink(receiveCompletion: { _ in
                
                Self.removeLanguageDownloadObserver(languageId: languageId)
                
            }, receiveValue: { (progress: Double) in
                
                Self.languageDownloaderObservers[languageId]?.send(progress)
                
                if progress >= 1 {
                    Self.removeLanguageDownloadObserver(languageId: languageId)
                }
            })
            .store(in: &backgroundCancellables)
    }
    
    private static func removeLanguageDownloadObserver(languageId: String) {
        Self.languageDownloaderObservers[languageId] = nil
    }
}

// MARK: - Mark For Removal Timer

extension DownloadableLanguageItemViewModel {
    
    private func observeResetMarkedForRemovalTimer() {
        
        guard let passthroughValueSubject = Self.markedForRemovalTimerObservers[languageId] else {
            return
        }
        
        let languageId: String = self.languageId
        
        passthroughValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (void: Void) in
                
                self?.isMarkedForRemoval = false
                Self.removeMarkedForRemovalTimerObserver(languageId: languageId)
            }
            .store(in: &cancellables)
    }
    
    private static func startResetMarkedForRemovalTimer(languageId: String) {
        
        Self.markedForRemovalTimerObservers[languageId] = PassthroughSubject()
                
        Timer.publish(
            every: Self.endMarkedForRemovalAfterSeconds,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { _ in
            
            Self.markedForRemovalTimerObservers[languageId]?.send(Void())
            
            Self.removeMarkedForRemovalTimerObserver(languageId: languageId)
        }
        .store(in: &Self.backgroundCancellables)
    }
    
    private static func removeMarkedForRemovalTimerObserver(languageId: String) {
        Self.markedForRemovalTimerObservers[languageId] = nil
    }
    
    static func removeAllResetMarkedForRemovalTimers() {
        Self.markedForRemovalTimerObservers.removeAll()
    }
}

// MARK: - Inputs

extension DownloadableLanguageItemViewModel {
    
    func languageTapped() {
        
        switch downloadState {
            
        case .downloaded:
            
            if isMarkedForRemoval {
                
                Self.removeMarkedForRemovalTimerObserver(languageId: languageId)
                isMarkedForRemoval = false
                removeDownloadedLanguage()
            }
            else {
                
                isMarkedForRemoval = true
                Self.startResetMarkedForRemovalTimer(languageId: languageId)
                observeResetMarkedForRemovalTimer()
            }
            
        case .downloading( _):
            break
            
        case .failed:
            break
            
        case .notDownloaded:

            if !Self.isDownloadingLanguage(languageId: languageId) {
             
                Self.downloadLanguageInBackground(
                    downloadToolLanguageUseCase: downloadToolLanguageUseCase,
                    languageId: languageId
                )
                
                observeLanguageDownload()
            }
        }
    }
}
