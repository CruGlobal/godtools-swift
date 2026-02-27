//
//  DownloadToolProgressViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class DownloadToolProgressViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase
    private let progressTimer: ProgressTimer = ProgressTimer()
    private let initialProgressDownloadLengthSeconds: TimeInterval = 1
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didCompleteToolDownload: Bool = false
    private var didCompleteProgressTimerClosure: (() -> Void)?
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = DownloadToolProgressStringsDomainModel.emptyValue
        
    init(flowDelegate: FlowDelegate, toolId: String?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase) {
                
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDownloadToolProgressStringsUseCase = getDownloadToolProgressStringsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        progressTimer.start(lengthSeconds: initialProgressDownloadLengthSeconds, changed: { (progress: Double) in

        }, completed: { [weak self] in
            self?.didCompleteProgressTimerClosure?()
        })
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getDownloadToolProgressStringsUseCase
                    .execute(toolId: toolId, appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: DownloadToolProgressStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        progressTimer.stop()
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
