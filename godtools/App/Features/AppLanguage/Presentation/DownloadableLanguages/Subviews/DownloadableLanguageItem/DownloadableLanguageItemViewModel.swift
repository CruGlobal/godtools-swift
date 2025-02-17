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
    private static var markForRemovalTimers: [LanguageId: SwiftUITimer] = Dictionary()
    
    private let downloadableLanguage: DownloadableLanguageListItemDomainModel
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
        
    @Published private(set) var languageNameInOwnLanguage: String
    @Published private(set) var languageNameInAppLanguage: String
    @Published private(set) var toolsAvailableText: String
    @Published private(set) var downloadState: DownloadableLanguageDownloadState
    @Published private(set) var isMarkedForRemoval: Bool = false
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.languageNameInOwnLanguage = downloadableLanguage.languageNameInAppLanguage
        self.languageNameInAppLanguage = downloadableLanguage.languageNameInAppLanguage
        self.toolsAvailableText = downloadableLanguage.toolsAvailableText
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
        
        if let downloadHandler = Self.downloadHandlers[languageId],
           let downloadProgress = downloadHandler.downloadProgress,
           downloadHandler.downloadFinished == false {
            
            downloadState = .downloading(progress: downloadProgress)
            
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
                
        if Self.markForRemovalTimers[languageId] != nil {
            startResetMarkedForRemovalTimer()
        }
        
        syncIconState()
    }
    
    deinit {
        
        if downloadableLanguage.languageNameInOwnLanguage.lowercased() == "english" {
            print("x deinit \(downloadableLanguage.languageNameInOwnLanguage) : \(type(of: self))")
        }
    }
    
    private func getLanguageDownloadHandler() -> DownloadableLanguagesDownloadHandler {
        
        if let existingHandler = Self.downloadHandlers[languageId] {
            return existingHandler
        }
        
        let newHandler = DownloadableLanguagesDownloadHandler(
            downloadToolLanguageUseCase: downloadToolLanguageUseCase,
            downloadableLanguage: downloadableLanguage
        )
        
        Self.downloadHandlers[languageId] = newHandler
        
        return newHandler
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
    
    private func getResetMarkedForRemovalTimer() -> SwiftUITimer {
        
        if let existingTimer = Self.markForRemovalTimers[languageId] {
            return existingTimer
        }
        
        let timer = SwiftUITimer(intervalSeconds: Self.endMarkedForRemovalAfterSeconds)
        
        Self.markForRemovalTimers[languageId] = timer
        
        return timer
    }
    
    private func startResetMarkedForRemovalTimer() {
                    
        isMarkedForRemoval = true
        
        let languageId: String = self.languageId
        let timer = getResetMarkedForRemovalTimer()
        
        timer.startPublisher()
            .sink { [weak self] _ in
                
                print("Mark for removal timer completed...")
                
                self?.isMarkedForRemoval = false
                
                Self.markForRemovalTimers[languageId]?.invalidate()
                Self.markForRemovalTimers[languageId] = nil
            }
            .store(in: &Self.backgroundCancellables)
                
        Self.markForRemovalTimers[languageId] = timer
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
                
                isMarkedForRemoval = false
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
            let downloadHandler: DownloadableLanguagesDownloadHandler = getLanguageDownloadHandler()
            
            downloadHandler.downloadLanguage(delegate: self)
        }
    }
}

// MARK: - DownloadableLanguagesDownloadHandlerDelegate

extension DownloadableLanguageItemViewModel: DownloadableLanguagesDownloadHandlerDelegate {
    
    func handlerDownloadComplete(handler: DownloadableLanguagesDownloadHandler, error: (any Error)?) {
        
        downloadState = .downloaded
        
        Self.downloadHandlers[languageId] = nil
        
        // TODO: Handle error? ~Levi
        
        if let error = error {
            
        }
        else {
            
        }
    }
    
    func handlerDownloadProgressUpdate(handler: DownloadableLanguagesDownloadHandler, progress: Double) {
        
        downloadState = .downloading(progress: progress)
    }
}
