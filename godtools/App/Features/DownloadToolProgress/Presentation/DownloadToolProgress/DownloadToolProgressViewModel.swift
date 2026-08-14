//
//  DownloadToolProgressViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class DownloadToolProgressViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let toolId: String?
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase
    private let progressTimer: ProgressTimer = ProgressTimer()
    private let initialProgressDownloadLengthSeconds: TimeInterval = 1
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didCompleteToolDownload: Bool = false
    private var didCompleteProgressTimerClosure: (() -> Void)?
            
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = DownloadToolProgressStringsDomainModel.emptyValue
        
    init(
        stepEmitter: FlowStepEmitter,
        toolId: String?,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getDownloadToolProgressStringsUseCase: GetDownloadToolProgressStringsUseCase
    ) {
                
        self.stepEmitter = stepEmitter
        self.toolId = toolId
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDownloadToolProgressStringsUseCase = getDownloadToolProgressStringsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
        
        progressTimer.start(lengthSeconds: initialProgressDownloadLengthSeconds, changed: { (progress: Double) in

        }, completed: { [weak self] in
            self?.didCompleteProgressTimerClosure?()
        })
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        progressTimer.stop()
    }
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            strings = await getDownloadToolProgressStringsUseCase
                .execute(toolId: toolId, appLanguage: appLanguage)
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
                
        stepEmitter.emit(step: AppFlowStep.closeTappedFromDownloadTool)
    }
}
