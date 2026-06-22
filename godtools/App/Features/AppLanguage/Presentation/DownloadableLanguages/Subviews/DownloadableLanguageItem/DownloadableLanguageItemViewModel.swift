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
    
    private static var languageDownloadCancellables: [LanguageId: AnyCancellable] = Dictionary()
    private static var resetIsMarkedForRemovalTimers: [LanguageId: SwiftUITimer] = Dictionary()
    private static var downloadState: [LanguageId: DownloadableLanguageDownloadState] = Dictionary()
    private static var isMarkedForRemoval: [LanguageId: Bool] = Dictionary()
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    
    @Published private(set) var downloadState: DownloadableLanguageDownloadState
    @Published private(set) var isMarkedForRemoval: Bool
    @Published private(set) var iconState: LanguageDownloadIcon.State = .notDownloaded
    @Published private(set) var downloadError: Error?
    
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
        
        if let downloadState = Self.downloadState[languageId] {

            self.downloadState = downloadState
        }
        else {
            
            switch downloadableLanguage.downloadStatus {
            case .notDownloaded:
                downloadState = .notDownloaded
            case .downloaded( _):
                downloadState = .downloaded
            }
        }
        
        isMarkedForRemoval = Self.isMarkedForRemoval[languageId] ?? false
        
        Publishers.CombineLatest(
            $downloadState,
            $isMarkedForRemoval
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
        .assign(to: &$iconState)
        
        // TODO: Would be nice to handle errors per item. ~Levi
        $downloadError
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
}

// MARK: - Remove Downloaded Language

extension DownloadableLanguageItemViewModel {
    
    private func removeDownloadedLanguage() {
        
        setDownloadState(state: .notDownloaded)
        
        Task {
            try await removeDownloadedToolLanguageUseCase.execute(languageId: languageId)
        }
    }
}

// MARK: - Download Language

extension DownloadableLanguageItemViewModel {
    
    private var isDownloading: Bool {
        return downloadState.isDownloading || Self.languageDownloadCancellables[languageId] != nil
    }
    
    private func setDownloadState(state: DownloadableLanguageDownloadState) {
        
        print("\n ViewModel set download state: \(state)")
        
        downloadState = state
        
        Self.downloadState[languageId] = state
        
        if state == .downloaded {
            Self.languageDownloadCancellables[languageId] = nil
        }
    }
    
    private func cancelLanguageDownload() {
        
        Self.languageDownloadCancellables[languageId]?.cancel()
        Self.languageDownloadCancellables[languageId] = nil
        
        setDownloadState(state: .notDownloaded)
    }
    
    private func startLanguageDownload() {
        
        guard !downloadState.isDownloading else {
            return
        }
        
        setDownloadState(state: .downloading(progress: 0))
                
        let languageId: String = self.languageId
                
        Self.languageDownloadCancellables[languageId] = downloadToolLanguageUseCase
            .execute(languageId: languageId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                
                switch completion {
                case .finished:
                    self?.setDownloadState(state: .downloaded)
                case .failure(let error):
                    // TODO: Handle errors? ~Levi
                    //self?.downloadError = error
                    //self?.setDownloadState(state: .notDownloaded)
                    self?.setDownloadState(state: .downloaded)
                }
                
                Self.languageDownloadCancellables[languageId] = nil
                
            } receiveValue: { [weak self] (progress: Double) in
                
                let state: DownloadableLanguageDownloadState
                
                if progress < 1 {
                    state = .downloading(progress: progress)
                } else {
                    state = .downloaded
                }
                
                self?.setDownloadState(state: state)
            }
    }
}

// MARK: - Mark For Removal Timer

extension DownloadableLanguageItemViewModel {
    
    private func setIsMarkedForRemoval(isMarkedForRemoval: Bool) {
        
        self.isMarkedForRemoval = isMarkedForRemoval
        
        Self.isMarkedForRemoval[languageId] = isMarkedForRemoval
    }
    
    private func startResetIsMarkedForRemovalTimer(completion: (() -> Void)?) {
                
        let timer = SwiftUITimer(
            intervalSeconds: Self.endMarkedForRemovalAfterSeconds,
            repeats: false
        )
        
        Self.resetIsMarkedForRemovalTimers[languageId] = timer
        
        timer.startPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                self?.stopResetIsMarkedForRemovalTimer()
                
                completion?()
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private func stopResetIsMarkedForRemovalTimer() {
        Self.resetIsMarkedForRemovalTimers[languageId]?.stop()
        Self.resetIsMarkedForRemovalTimers[languageId] = nil
    }
}

// MARK: - Inputs

extension DownloadableLanguageItemViewModel {
    
    func languageTapped() {
        
        switch downloadState {
            
        case .downloaded:
            
            if isMarkedForRemoval {
                
                setIsMarkedForRemoval(isMarkedForRemoval: false)
                stopResetIsMarkedForRemovalTimer()
                removeDownloadedLanguage()
            }
            else {
                
                setIsMarkedForRemoval(isMarkedForRemoval: true)
                startResetIsMarkedForRemovalTimer(completion: { [weak self] in
                    self?.setIsMarkedForRemoval(isMarkedForRemoval: false)
                })
            }
            
        case .downloading( _):
            break
            
        case .notDownloaded:
            startLanguageDownload()
        }
    }
}
