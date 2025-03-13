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
    
    private static let downloadProgress: ValueObserverContainer<Double?> = ValueObserverContainer(defaultValue: nil)
    private static let isMarkedForRemoval: ValueObserverContainer<Bool> = ValueObserverContainer(defaultValue: false)
    private static let endMarkedForRemovalAfterSeconds: TimeInterval = 3
    
    private static var languageDownloads: [LanguageId: AnimateDownloadProgress] = Dictionary()
    private static var resetIsMarkedForRemovalTimers: [LanguageId: SwiftUITimer] = Dictionary()
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    let isMarkedForRemoval: ValueObserver<Bool>
    
    @Published private(set) var downloadState: DownloadableLanguageDownloadState = .notDownloaded
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(flowDelegate: FlowDelegate, downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
        
        isMarkedForRemoval = Self.isMarkedForRemoval.observer(id: languageId)
        
        if let currentDownloadProgress = Self.downloadProgress.observer(id: languageId).value {
            
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
                
        sinkIconState()
        sinkLanguageDownloadProgress()
    }
    
    private var languageId: String {
        return downloadableLanguage.languageId
    }
    
    private func sinkIconState() {
        
        Publishers.CombineLatest(
            $downloadState,
            isMarkedForRemoval.$value
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
        .receive(on: DispatchQueue.main)
        .assign(to: &$iconState)
    }
    
    private func sinkLanguageDownloadProgress() {
        
        Self.downloadProgress
            .observer(id: languageId)
            .$value
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                
                switch completion {
                case .finished:
                    self?.downloadState = .downloaded
                case .failure(let error):
                    self?.downloadState = .notDownloaded
                    self?.flowDelegate?.navigate(step: .languageDownloadFailedFromDownloadedLanguages(error: error))
                }
                
            }, receiveValue: { [weak self] (progress: Double?) in
                
                guard let progress = progress else {
                    return
                }
                
                self?.downloadState = .downloading(progress: progress)
            })
            .store(in: &cancellables)
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
    
    private static func startLanguageDownload(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, languageId: String, flowDelegate: FlowDelegate?) {
                  
        let isDownloading: Bool = Self.downloadProgress.observer(id: languageId).value != nil

        guard !isDownloading else {
            return
        }
        
        let languageDownloadWithAnimateDownloadProgress = AnimateDownloadProgress()
        
        Self.downloadProgress.observer(id: languageId).value = 0
        Self.languageDownloads[languageId] = languageDownloadWithAnimateDownloadProgress
        
        languageDownloadWithAnimateDownloadProgress
            .start(downloadProgressPublisher: downloadToolLanguageUseCase.downloadToolLanguage(languageId: languageId))
            .sink { completion in
                
                Self.languageDownloads[languageId] = nil
                
                switch completion {
                case .finished:
                    Self.downloadProgress.removeObserver(id: languageId)
                case .failure(_):
                    Self.downloadProgress.observer(id: languageId).value = nil
                }
                
            } receiveValue: { (progress: Double) in
                
                Self.downloadProgress.observer(id: languageId).value = progress
            }
            .store(in: &backgroundCancellables)
    }
}

// MARK: - Mark For Removal Timer

extension DownloadableLanguageItemViewModel {
    
    private static func startResetIsMarkedForRemovalTimer(languageId: String) {
        
        let timer = SwiftUITimer(
            intervalSeconds: Self.endMarkedForRemovalAfterSeconds,
            repeats: false
        )
        
        Self.resetIsMarkedForRemovalTimers[languageId] = timer
        Self.isMarkedForRemoval.observer(id: languageId).value = true
        
        timer.startPublisher()
            .sink { _ in
                
                Self.stopResetIsMarkedForRemovalTimer(languageId: languageId)
                Self.isMarkedForRemoval.observer(id: languageId).value = false
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private static func stopResetIsMarkedForRemovalTimer(languageId: String) {
        Self.resetIsMarkedForRemovalTimers[languageId]?.stop()
        Self.resetIsMarkedForRemovalTimers[languageId] = nil
    }
    
    static func removeAllResetMarkedForRemovalTimers() {
        Self.isMarkedForRemoval.removeAllObservers()
        Self.resetIsMarkedForRemovalTimers.removeAll()
    }
}

// MARK: - Inputs

extension DownloadableLanguageItemViewModel {
    
    func languageTapped() {
        
        switch downloadState {
            
        case .downloaded:
            
            if isMarkedForRemoval.value {
                
                isMarkedForRemoval.value = false
                Self.stopResetIsMarkedForRemovalTimer(languageId: languageId)
                removeDownloadedLanguage()
            }
            else {
                
                isMarkedForRemoval.value = true
                Self.startResetIsMarkedForRemovalTimer(languageId: languageId)
            }
            
        case .downloading( _):
            break
            
        case .notDownloaded:
            Self.startLanguageDownload(
                downloadToolLanguageUseCase: downloadToolLanguageUseCase,
                languageId: languageId,
                flowDelegate: flowDelegate
            )
        }
    }
}
