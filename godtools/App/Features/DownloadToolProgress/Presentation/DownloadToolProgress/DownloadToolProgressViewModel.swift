//
//  DownloadToolProgressViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadToolProgressViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDownloadToolProgressInterfaceStringsUseCase: GetDownloadToolProgressInterfaceStringsUseCase
    private let getToolDownloadProgressInterfaceStringUseCase: GetToolDownloadProgressInterfaceStringUseCase
    private let progressTimer: ProgressTimer = ProgressTimer()
    private let initialProgressDownloadLengthSeconds: TimeInterval = 10
    private let pauseProgressTimerOnProgress: TimeInterval = 0.99
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didCompleteToolDownload: Bool = false
    private var didCompleteProgressTimerClosure: (() -> Void)?
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var message: String = ""
    @Published var downloadProgress: Double = 0
    @Published var downloadProgressString: String = ""
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDownloadToolProgressInterfaceStringsUseCase: GetDownloadToolProgressInterfaceStringsUseCase, getToolDownloadProgressInterfaceStringUseCase: GetToolDownloadProgressInterfaceStringUseCase) {
                
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDownloadToolProgressInterfaceStringsUseCase = getDownloadToolProgressInterfaceStringsUseCase
        self.getToolDownloadProgressInterfaceStringUseCase = getToolDownloadProgressInterfaceStringUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        progressTimer.start(lengthSeconds: initialProgressDownloadLengthSeconds, changed: { [weak self] (progress: Double) in
            self?.progressChanged(progress: progress)
        }, completed: { [weak self] in
            self?.didCompleteProgressTimerClosure?()
        })
        
        getDownloadToolProgressInterfaceStringsUseCase
            .getStringsPublisher(resource: resource, appLanguageCodeChangedPublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                
                self?.message = interfaceStrings.downloadMessage
            }
            .store(in: &cancellables)
        
        getToolDownloadProgressInterfaceStringUseCase
            .getDownloadProgress(
                appLanguageCodeChangedPublisher: $appLanguage.eraseToAnyPublisher(),
                downloadProgressChangedPublisher: $downloadProgress.eraseToAnyPublisher()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (toolDownloadProgress: ToolDownloadProgressDomainModel) in
                self?.downloadProgressString = toolDownloadProgress.value
            }
            .store(in: &cancellables)
    }
    
    deinit {
        progressTimer.stop()
    }
    
    private func progressChanged(progress: Double) {
        
        guard !progressTimer.isPaused else {
            return
        }
        
        if progress >= pauseProgressTimerOnProgress && !didCompleteToolDownload {
            
            progressTimer.pause(progress: pauseProgressTimerOnProgress)
            downloadProgress = pauseProgressTimerOnProgress
        }
        else {
            
            downloadProgress = progress
        }
    }
    
    func completeDownloadProgress(didCompleteProgress: @escaping (() -> Void)) {
        
        didCompleteToolDownload = true
        
        didCompleteProgressTimerClosure = didCompleteProgress
        
        if progressTimer.isPaused {
            
            progressTimer.resume()
        }
        else if progressTimer.isRunning {
            
            progressTimer.changeRemainingSeconds(seconds: 1)
        }
        else {
            
            didCompleteProgress()
        }
    }
}

// MARK: - Inputs

extension DownloadToolProgressViewModel {
    
    @objc func closeTapped() {
        
        progressTimer.stop()
                
        flowDelegate?.navigate(step: .closeTappedFromDownloadToolProgress)
    }
}
