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
    
    private static var didViewToolScreenShareTutorialCancellable: AnyCancellable?
    
    private let toolId: String
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewToolScreenShareTutorialUseCase: ViewToolScreenShareTutorialUseCase
    private let didViewToolScreenShareTutorialUseCase: DidViewToolScreenShareTutorialUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var interfaceStrings: ToolScreenShareInterfaceStringsDomainModel?
    
    @Published var hidesSkipButton: Bool = false
    @Published var tutorialPages: [ToolScreenShareTutorialPageDomainModel] = Array()
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0
    
    init(flowDelegate: FlowDelegate, toolId: String, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolScreenShareTutorialUseCase: ViewToolScreenShareTutorialUseCase, didViewToolScreenShareTutorialUseCase: DidViewToolScreenShareTutorialUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolScreenShareTutorialUseCase = viewToolScreenShareTutorialUseCase
        self.didViewToolScreenShareTutorialUseCase = didViewToolScreenShareTutorialUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        viewToolScreenShareTutorialUseCase
            .viewTutorialPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (toolScreenShareTutorial: ToolScreenShareTutorialDomainModel) in
                
                self?.interfaceStrings = toolScreenShareTutorial.interfaceStrings
                self?.tutorialPages = toolScreenShareTutorial.pages
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $currentPage.eraseToAnyPublisher(),
            $interfaceStrings.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (currentPage: Int, interfaceStrings: ToolScreenShareInterfaceStringsDomainModel?) in
            if let interfaceStrings = interfaceStrings {
                self?.refreshContinueTitle(interfaceStrings: interfaceStrings)
            }
        }
        .store(in: &cancellables)

        $currentPage
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (page: Int) in
                self?.pageDidChange(page: page)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return "shareToolScreen"
    }
    
    private var isOnLastPage: Bool {
        return currentPage >= tutorialPages.count - 1
    }
    
    private func pageDidChange(page: Int) {
                
        hidesSkipButton = isOnLastPage
    }
    
    private func refreshContinueTitle(interfaceStrings: ToolScreenShareInterfaceStringsDomainModel) {
        continueTitle = !isOnLastPage ? interfaceStrings.nextTutorialPageActionTitle : interfaceStrings.shareLinkActionTitle
    }
}

// MARK: - Inputs

extension ToolScreenShareTutorialViewModel {
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolScreenShareTutorial)
    }
    
    @objc func skipTapped() {
        
        let lastPage: Int = tutorialPages.count - 1
        currentPage = lastPage
    }
    
    func continueTapped() {
        
        if isOnLastPage {
            shareLinkTapped()
        }
        else {
            nextPageTapped()
        }
    }
    
    private func nextPageTapped() {
        currentPage = currentPage + 1
    }
    
    private func shareLinkTapped() {
        
        ToolScreenShareTutorialViewModel.didViewToolScreenShareTutorialCancellable = didViewToolScreenShareTutorialUseCase
            .didViewPublisher(toolId: toolId)
            .sink { _ in
                
            }
        
        flowDelegate?.navigate(step: .shareLinkTappedFromToolScreenShareTutorial)
    }
}
