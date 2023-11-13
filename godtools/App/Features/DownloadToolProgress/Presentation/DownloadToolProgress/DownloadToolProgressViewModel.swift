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
    private let progressTimer: ProgressTimer = ProgressTimer()
    private let initialProgressDownloadLengthSeconds: TimeInterval = 1
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didCompleteToolDownload: Bool = false
    private var didCompleteProgressTimerClosure: (() -> Void)?
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var message: String = ""
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDownloadToolProgressInterfaceStringsUseCase: GetDownloadToolProgressInterfaceStringsUseCase) {
                
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDownloadToolProgressInterfaceStringsUseCase = getDownloadToolProgressInterfaceStringsUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        progressTimer.start(lengthSeconds: initialProgressDownloadLengthSeconds, changed: { (progress: Double) in

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
    }
    
    deinit {
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
