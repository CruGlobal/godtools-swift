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
    private let getResumeLessonProgressStringsUseCase: GetResumeLessonProgressStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings = ResumeLessonProgressStringsDomainModel.emptyValue
    
    init(flowDelegate: FlowDelegate, getResumeLessonProgressStringsUseCase: GetResumeLessonProgressStringsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getResumeLessonProgressStringsUseCase = getResumeLessonProgressStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getResumeLessonProgressStringsUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ResumeLessonProgressStringsDomainModel) in
                
                self?.strings = strings
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
