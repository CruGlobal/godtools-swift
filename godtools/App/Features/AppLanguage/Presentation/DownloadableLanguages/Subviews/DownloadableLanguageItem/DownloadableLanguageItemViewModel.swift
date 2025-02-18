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
    private static var downloadHandlers: [LanguageId: DownloadableLanguagesDownloadHandler] = Dictionary()
    private static var markForRemovalTimers: [LanguageId: AnyPublisher<Date, Never>] = Dictionary()
        
    private let downloadableLanguage: DownloadableLanguageListItemDomainModel
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
        
    @Published private(set) var languageNameInOwnLanguage: String
    @Published private(set) var languageNameInAppLanguage: String
    @Published private(set) var toolsAvailableText: String
    @Published private(set) var downloadState: DownloadableLanguageDownloadState
    @Published private(set) var isMarkedForRemoval: Bool
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.languageNameInOwnLanguage = downloadableLanguage.languageNameInAppLanguage
        self.languageNameInAppLanguage = downloadableLanguage.languageNameInAppLanguage
        self.toolsAvailableText = downloadableLanguage.toolsAvailableText
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
        
        isMarkedForRemoval = Self.markForRemovalTimers[languageId] != nil
        
        if let downloadHandler = Self.downloadHandlers[languageId] {
            
            if let progress = downloadHandler.downloadProgress {
                downloadState = .downloading(progress: progress)
            }
            else {
                downloadState = downloadHandler.downloadFinished ? .downloaded : .notDownloaded
            }

            downloadHandler.setDelegate(self)
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
        
        if let markForRemovalTimerPublisher = Self.markForRemovalTimers[languageId] {
            syncResetMarkedForRemovalTimerPublisher(timerPublisher: markForRemovalTimerPublisher)
        }
    }
    
    deinit {
        
        if downloadableLanguage.languageNameInOwnLanguage.lowercased() == "english" {
            print("x deinit \(downloadableLanguage.languageNameInOwnLanguage) : \(type(of: self))")
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
    
    private func downloadLanguage() {
        
        let downloadHandler = DownloadableLanguagesDownloadHandler(
            downloadToolLanguageUseCase: downloadToolLanguageUseCase,
            downloadableLanguage: downloadableLanguage
        )
        
        Self.downloadHandlers[languageId] = downloadHandler
        
        downloadHandler.startDownload(delegate: self)
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
        
        let languageId: String = self.languageId
        
        let timer = Timer.publish(
            every: Self.endMarkedForRemovalAfterSeconds,
            on: .main,
            in: .common
        ).autoconnect()
                
        let timerPublisher = timer.eraseToAnyPublisher()
        
        Self.markForRemovalTimers[languageId] = timerPublisher
        
        syncResetMarkedForRemovalTimerPublisher(timerPublisher: timerPublisher)
    }
    
    private func syncResetMarkedForRemovalTimerPublisher(timerPublisher: AnyPublisher<Date, Never>) {

        timerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopResetMarkedForRemovalTimer()
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private func stopResetMarkedForRemovalTimer() {
        
        isMarkedForRemoval = false
        
        Self.markForRemovalTimers[languageId] = nil
    }
    
    static func removeAllResetMarkedForRemovalTimers() {
        Self.markForRemovalTimers.removeAll()
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

// MARK: - DownloadableLanguagesDownloadHandlerDelegate

extension DownloadableLanguageItemViewModel: DownloadableLanguagesDownloadHandlerDelegate {
    
    func downloadableLanguagesDownloadHandlerCompleted(handler: DownloadableLanguagesDownloadHandler, error: (any Error)?) {
        
        downloadState = .downloaded
        
        Self.downloadHandlers[languageId] = nil
        
        // TODO: Handle error? ~Levi
        
        if let error = error {
            print(error)
        }
        else {
            
        }
    }
    
    func downloadableLanguagesDownloadHandlerProgressChanged(handler: DownloadableLanguagesDownloadHandler, progress: Double) {
        
        downloadState = .downloading(progress: progress)
    }
}
