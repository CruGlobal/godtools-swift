//
//  LessonSwipeTutorialViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LessonSwipeTutorialViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let getStringsUseCase: GetLessonSwipeTutorialStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings: LessonSwipeTutorialStringsDomainModel = LessonSwipeTutorialStringsDomainModel.emptyValue

    init(stepEmitter: FlowStepEmitter, getStringsUseCase: GetLessonSwipeTutorialStringsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        self.stepEmitter = stepEmitter
        self.getStringsUseCase = getStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getStringsUseCase
                    .execute(translateInLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: LessonSwipeTutorialStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension LessonSwipeTutorialViewModel {
    
    func dismissTutorial() {
        stepEmitter.emit(step: AppFlowStep.closeLessonSwipeTutorial)
    }
}
