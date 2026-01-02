//
//  DownloadableLanguageItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class DownloadableLanguageItemViewModel: ObservableObject {
    
    typealias LanguageId = String
    
    private static let endMarkedForRemovalAfterSeconds: TimeInterval = 3
    
    private static var inMemoryStateForRecycle: [LanguageId: DownloadableLanguageItemRecycleState] = Dictionary()
    private static var languageDownloads: [LanguageId: AnimateDownloadProgress] = Dictionary()
    private static var resetIsMarkedForRemovalTimers: [LanguageId: SwiftUITimer] = Dictionary()
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    let recycleState: DownloadableLanguageItemRecycleState
    
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(flowDelegate: FlowDelegate, downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
        
        if let existingRecycleState = Self.inMemoryStateForRecycle[languageId] {
            recycleState = existingRecycleState
        }
        else {
            recycleState = DownloadableLanguageItemRecycleState(downloadableLanguage: downloadableLanguage)
            Self.inMemoryStateForRecycle[languageId] = recycleState
        }
             
        Publishers.CombineLatest(
            recycleState.$downloadState,
            recycleState.$isMarkedForRemoval
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
                case .notDownloaded:
                    iconState = .notDownloaded
                }
            }
            
            return Just(iconState)
                .eraseToAnyPublisher()
        }
        .assign(to: &$iconState)
        
        recycleState
            .$downloadError
            .sink(receiveValue: { [weak self] (downloadError: Error?) in
                if let downloadError = downloadError {
                    self?.flowDelegate?.navigate(step: .languageDownloadFailedFromDownloadedLanguages(error: downloadError))
                }
            })
            .store(in: &cancellables)
    }
    
    private var languageId: String {
        return downloadableLanguage.languageId
    }
    
    static func removeInMemoryRecycleState() {
        Self.inMemoryStateForRecycle.removeAll()
    }
    
    static func removeMarkedForRemovalTimers() {
        Self.resetIsMarkedForRemovalTimers.removeAll()
    }
}

// MARK: - Remove Downloaded Language

extension DownloadableLanguageItemViewModel {
    
    private func removeDownloadedLanguage() {
        
        recycleState.downloadState = .notDownloaded
        
        removeDownloadedToolLanguageUseCase
            .removeDownloadedToolLanguage(languageId)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            }
            .store(in: &Self.backgroundCancellables)
    }
}

// MARK: - Download Language

extension DownloadableLanguageItemViewModel {
    
    private static func startLanguageDownload(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, recycleState: DownloadableLanguageItemRecycleState, languageId: String, flowDelegate: FlowDelegate?) {
                  
        let isDownloading: Bool = recycleState.downloadState.isDownloading

        guard !isDownloading else {
            return
        }
        
        let languageDownloadWithAnimateDownloadProgress = AnimateDownloadProgress()
        
        recycleState.downloadState = .downloading(progress: 0)
        Self.languageDownloads[languageId] = languageDownloadWithAnimateDownloadProgress
        
        languageDownloadWithAnimateDownloadProgress
            .start(downloadProgressPublisher: downloadToolLanguageUseCase.downloadToolLanguage(languageId: languageId))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
                Self.languageDownloads[languageId] = nil
                
                switch completion {
                case .finished:
                    recycleState.downloadState = .downloaded
                case .failure(let error):
                    recycleState.downloadError = error
                    recycleState.downloadError = nil
                    recycleState.downloadState = .notDownloaded
                }
                
            } receiveValue: { (progress: Double) in
                
                recycleState.downloadState = .downloading(progress: progress)
            }
            .store(in: &backgroundCancellables)
    }
}

// MARK: - Mark For Removal Timer

extension DownloadableLanguageItemViewModel {
    
    private static func startResetIsMarkedForRemovalTimer(recycleState: DownloadableLanguageItemRecycleState, languageId: String) {
        
        let timer = SwiftUITimer(
            intervalSeconds: Self.endMarkedForRemovalAfterSeconds,
            repeats: false
        )
        
        Self.resetIsMarkedForRemovalTimers[languageId] = timer
        recycleState.isMarkedForRemoval = true
        
        timer.startPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
                Self.stopResetIsMarkedForRemovalTimer(languageId: languageId)
                recycleState.isMarkedForRemoval = false
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private static func stopResetIsMarkedForRemovalTimer(languageId: String) {
        Self.resetIsMarkedForRemovalTimers[languageId]?.stop()
        Self.resetIsMarkedForRemovalTimers[languageId] = nil
    }
}

// MARK: - Inputs

extension DownloadableLanguageItemViewModel {
    
    func languageTapped() {
        
        switch recycleState.downloadState {
            
        case .downloaded:
            
            if recycleState.isMarkedForRemoval {
                
                recycleState.isMarkedForRemoval = false
                Self.stopResetIsMarkedForRemovalTimer(languageId: languageId)
                removeDownloadedLanguage()
            }
            else {
                
                recycleState.isMarkedForRemoval = true
                Self.startResetIsMarkedForRemovalTimer(recycleState: recycleState, languageId: languageId)
            }
            
        case .downloading( _):
            break
            
        case .notDownloaded:
            Self.startLanguageDownload(
                downloadToolLanguageUseCase: downloadToolLanguageUseCase,
                recycleState: recycleState,
                languageId: languageId,
                flowDelegate: flowDelegate
            )
        }
    }
}
