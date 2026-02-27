//
//  LessonSwipeTutorialViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LessonSwipeTutorialViewModel: ObservableObject {
    
    private let getStringsUseCase: GetLessonSwipeTutorialStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings: LessonSwipeTutorialStringsDomainModel = LessonSwipeTutorialStringsDomainModel.emptyValue

    init(flowDelegate: FlowDelegate, getStringsUseCase: GetLessonSwipeTutorialStringsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        self.flowDelegate = flowDelegate
        self.getStringsUseCase = getStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
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
        flowDelegate?.navigate(step: .closeLessonSwipeTutorial)
    }
}
