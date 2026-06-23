//
//  DownloadableLanguageItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
class DownloadableLanguageItemViewModel: ObservableObject {
    
    typealias LanguageId = String
    
    private static let endMarkedForRemovalAfterSeconds: TimeInterval = 3
    
    private static var inMemoryStateForRecycle: [LanguageId: DownloadableLanguageItemRecycleState] = Dictionary()
    private static var languageDownloads: [LanguageId: AnyCancellable] = Dictionary()
    private static var resetIsMarkedForRemovalTimers: [LanguageId: SwiftUITimer] = Dictionary()
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    let recycleState: DownloadableLanguageItemRecycleState
    
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(
        stepEmitter: FlowStepEmitter,
        downloadableLanguage: DownloadableLanguageListItemDomainModel,
        downloadToolLanguageUseCase: DownloadToolLanguageUseCase,
        removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    ) {
        
        self.stepEmitter = stepEmitter
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
        .map { (downloadState: DownloadableLanguageDownloadState, isMarkedForRemoval: Bool) in
                        
            guard !isMarkedForRemoval else {
                return .remove
            }
            
            switch downloadState {
            case .downloaded:
                return .downloaded
            case .downloading(let progress):
                return .downloading(progress: progress)
            case .notDownloaded:
                return .notDownloaded
            }
        }
        .sink { [weak self] (iconState: LanguageDownloadIconState) in
                        
            self?.iconState = iconState
        }
        .store(in: &cancellables)
        
        // TODO: Would be nice to handle errors per item. ~Levi
        recycleState
            .$downloadError
            .sink(receiveValue: { [weak self] (downloadError: Error?) in
                if let downloadError = downloadError {
                    self?.stepEmitter.emit(step: AppFlowStep.languageDownloadFailedFromDownloadedLanguages(error: downloadError))
                }
            })
            .store(in: &cancellables)
    }
    
    deinit {
        //print("x deinit: \(type(of: self))")
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
        
        Task {
            try await removeDownloadedToolLanguageUseCase.execute(languageId: languageId)
        }
    }
}

// MARK: - Download Language

extension DownloadableLanguageItemViewModel {
    
    private static func startLanguageDownload(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, recycleState: DownloadableLanguageItemRecycleState, languageId: String) {
                  
        let isDownloading: Bool = recycleState.downloadState.isDownloading

        guard !isDownloading else {
            return
        }
                
        recycleState.downloadState = .downloading(progress: 0)
        
        Self.languageDownloads[languageId] = downloadToolLanguageUseCase
            .execute(languageId: languageId)
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
                
                if progress < 1 {
                    recycleState.downloadState = .downloading(progress: progress)
                }
                else {
                    recycleState.downloadState = .downloaded
                }
            }
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
                languageId: languageId
            )
        }
    }
}
