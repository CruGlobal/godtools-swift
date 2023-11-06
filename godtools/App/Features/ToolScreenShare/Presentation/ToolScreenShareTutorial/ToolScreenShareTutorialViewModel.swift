//
//  ToolScreenShareTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolScreenShareTutorialViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolScreenShareTutorialUseCase: GetToolScreenShareTutorialUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var tutorialPages: [ToolScreenShareTutorialPageDomainModel] = Array()
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolScreenShareTutorialUseCase: GetToolScreenShareTutorialUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolScreenShareTutorialUseCase = getToolScreenShareTutorialUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        getToolScreenShareTutorialUseCase
            .getTutorialPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (toolScreenShareTutorial: ToolScreenShareTutorialDomainModel) in
                
                self?.tutorialPages = toolScreenShareTutorial.pages
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension ToolScreenShareTutorialViewModel {
    
    func continueTapped() {
        
    }
}
