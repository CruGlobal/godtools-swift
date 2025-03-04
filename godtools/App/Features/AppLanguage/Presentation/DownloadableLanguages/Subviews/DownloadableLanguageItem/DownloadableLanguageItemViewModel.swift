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
    
    private static var languageDownloadProgress: CurrentValueContainer<Double, Error> = CurrentValueContainer()
    private static var languageDownloads: [LanguageId: AnimateDownloadProgress] = Dictionary()
    private static var isMarkedForRemoval: CurrentValueContainer<Bool, Never> = CurrentValueContainer()
    private static var resetIsMarkedForRemovalTimers: [LanguageId: SwiftUITimer] = Dictionary()
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let downloadToolLanguageUseCase: DownloadToolLanguageUseCase
    private let removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let downloadableLanguage: DownloadableLanguageListItemDomainModel
    
    @Published private(set) var downloadState: DownloadableLanguageDownloadState
    @Published private(set) var isMarkedForRemoval: Bool
    @Published private(set) var iconState: LanguageDownloadIconState = .notDownloaded
    
    init(flowDelegate: FlowDelegate, downloadableLanguage: DownloadableLanguageListItemDomainModel, downloadToolLanguageUseCase: DownloadToolLanguageUseCase, removeDownloadedToolLanguageUseCase: RemoveDownloadedToolLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.downloadableLanguage = downloadableLanguage
        self.downloadToolLanguageUseCase = downloadToolLanguageUseCase
        self.removeDownloadedToolLanguageUseCase = removeDownloadedToolLanguageUseCase
        
        let languageId: String = downloadableLanguage.languageId
                
        if let currentDownloadProgress = Self.languageDownloadProgress.getValue(id: languageId) {
            
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
        
        isMarkedForRemoval = Self.isMarkedForRemoval.getValue(id: languageId) ?? false
        
        sinkIconState()
        sinkLanguageDownloadProgress()
        sinkIsMarkedForRemoval()
    }
    
    private var languageId: String {
        return downloadableLanguage.languageId
    }
    
    private func sinkIconState() {
        
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
        
        Self.languageDownloadProgress
            .getPublisher(id: languageId)
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
    
    private func sinkIsMarkedForRemoval() {
        
        Self.isMarkedForRemoval
            .getPublisher(id: languageId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isMarkedForRemoval: Bool?) in
                self?.isMarkedForRemoval = isMarkedForRemoval ?? false
            }
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
    
    private func startLanguageDownloadIfNeeded() {
        
        guard !Self.isDownloadingLanguage(languageId: languageId) else {
            return
        }
        
        Self.downloadLanguageInBackground(
            downloadToolLanguageUseCase: downloadToolLanguageUseCase,
            languageId: languageId,
            flowDelegate: flowDelegate
        )
    }
    
    private static func isDownloadingLanguage(languageId: String) -> Bool {
        return Self.languageDownloadProgress.getValue(id: languageId) != nil
    }
    
    private static func downloadLanguageInBackground(downloadToolLanguageUseCase: DownloadToolLanguageUseCase, languageId: String, flowDelegate: FlowDelegate?) {
                   
        let languageDownloadWithAnimateDownloadProgress = AnimateDownloadProgress()
        
        Self.languageDownloadProgress.sendValue(id: languageId, value: 0)
        Self.languageDownloads[languageId] = languageDownloadWithAnimateDownloadProgress
        
        languageDownloadWithAnimateDownloadProgress
            .start(downloadProgressPublisher: downloadToolLanguageUseCase.downloadToolLanguage(languageId: languageId))
            .sink { completion in
                
                Self.languageDownloadProgress.sendCompletion(id: languageId, completion: completion)
                Self.languageDownloadProgress.remove(id: languageId)
                Self.languageDownloads[languageId] = nil
                
            } receiveValue: { (progress: Double) in
                
                Self.languageDownloadProgress.sendValue(id: languageId, value: progress)
            }
            .store(in: &backgroundCancellables)
    }
}

// MARK: - Mark For Removal Timer

extension DownloadableLanguageItemViewModel {
    
    private func startResetIsMarkedForRemovalTimer() {
        Self.startResetIsMarkedForRemovalTimer(languageId: languageId)
    }
    
    private func stopResetIsMarkedForRemovalTimer() {
        Self.stopResetIsMarkedForRemovalTimer(languageId: languageId)
    }
    
    private static func startResetIsMarkedForRemovalTimer(languageId: String) {
        
        let timer = SwiftUITimer(
            intervalSeconds: Self.endMarkedForRemovalAfterSeconds,
            repeats: false
        )
        
        Self.resetIsMarkedForRemovalTimers[languageId] = timer
        Self.isMarkedForRemoval.sendValue(id: languageId, value: true)
        
        timer.startPublisher()
            .sink { _ in
                
                Self.stopResetIsMarkedForRemovalTimer(languageId: languageId)
                Self.isMarkedForRemoval.sendValue(id: languageId, value: false)
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private static func stopResetIsMarkedForRemovalTimer(languageId: String) {
        Self.resetIsMarkedForRemovalTimers[languageId]?.stop()
        Self.resetIsMarkedForRemovalTimers[languageId] = nil
    }
    
    static func removeAllResetMarkedForRemovalTimers() {
        Self.isMarkedForRemoval.removeAll()
        Self.resetIsMarkedForRemovalTimers.removeAll()
    }
}

// MARK: - Inputs

extension DownloadableLanguageItemViewModel {
    
    func languageTapped() {
        
        switch downloadState {
            
        case .downloaded:
            
            if isMarkedForRemoval {
                
                isMarkedForRemoval = false
                stopResetIsMarkedForRemovalTimer()
                removeDownloadedLanguage()
            }
            else {
                
                isMarkedForRemoval = true
                startResetIsMarkedForRemovalTimer()
            }
            
        case .downloading( _):
            break
            
        case .notDownloaded:
            startLanguageDownloadIfNeeded()
        }
    }
}
