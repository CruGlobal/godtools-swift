//
//  ResumeLessonProgressModalViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class ResumeLessonProgressModalViewModel: ObservableObject {
    
    private weak var flowDelegate: FlowDelegate?
    private let getInterfaceStringsUseCase: GetResumeLessonProgressModalInterfaceStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var interfaceStringsDomainModel: ResumeLessonProgressModalInterfaceStringsDomainModel = ResumeLessonProgressModalInterfaceStringsDomainModel.emptyStrings()
    
    init(flowDelegate: FlowDelegate, getInterfaceStringsUseCase: GetResumeLessonProgressModalInterfaceStringsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        self.flowDelegate = flowDelegate
        self.getInterfaceStringsUseCase = getInterfaceStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getInterfaceStringsUseCase.getStringsPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] interfaceStrings in
                
                self?.interfaceStringsDomainModel = interfaceStrings
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Inputs
    
    func startOverButtonTapped() {
        flowDelegate?.navigate(step: .startOverTappedFromResumeLessonModal)
    }
    
    func continueButtonTapped() {
        flowDelegate?.navigate(step: .continueTappedFromResumeLessonModal)
    }
}
