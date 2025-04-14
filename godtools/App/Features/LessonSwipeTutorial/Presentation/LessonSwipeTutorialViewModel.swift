//
//  LessonSwipeTutorialViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonSwipeTutorialViewModel: ObservableObject {
    
    private weak var flowDelegate: FlowDelegate?
    private let getInterfaceStringsUseCase: GetLessonSwipeTutorialInterfaceStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var interfaceStrings: LessonSwipeTutorialInterfaceStringsDomainModel = LessonSwipeTutorialInterfaceStringsDomainModel.emptyStrings()

    init(flowDelegate: FlowDelegate, getInterfaceStringsUseCase: GetLessonSwipeTutorialInterfaceStringsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        self.flowDelegate = flowDelegate
        self.getInterfaceStringsUseCase = getInterfaceStringsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
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
                
                self?.interfaceStrings = interfaceStrings
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Input
    
    func dismissTutorial() {
        flowDelegate?.navigate(step: .closeLessonSwipeTutorial)
    }
}
