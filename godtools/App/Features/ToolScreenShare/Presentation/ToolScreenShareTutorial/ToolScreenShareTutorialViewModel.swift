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
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewToolScreenShareTutorialUseCase
                    .viewTutorialPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (toolScreenShareTutorial: ToolScreenShareTutorialDomainModel) in
                
                self?.interfaceStrings = toolScreenShareTutorial.interfaceStrings
                self?.tutorialPages = toolScreenShareTutorial.pages
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $currentPage,
            $interfaceStrings,
            $tutorialPages.dropFirst()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (currentPage: Int, interfaceStrings: ToolScreenShareInterfaceStringsDomainModel?, tutorialPages: [ToolScreenShareTutorialPageDomainModel]) in
            
            guard let weakSelf = self else {
                return
            }
            
            if let interfaceStrings = interfaceStrings {
                weakSelf.refreshContinueTitle(interfaceStrings: interfaceStrings, tutorialPages: tutorialPages)
            }
        }
        .store(in: &cancellables)

        Publishers.CombineLatest(
            $currentPage,
            $tutorialPages.dropFirst()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (page: Int, tutorialPages: [ToolScreenShareTutorialPageDomainModel]) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.hidesSkipButton = weakSelf.getIsOnLastPage(tutorialPages: tutorialPages)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return "shareToolScreen"
    }
    
    private func getIsOnLastPage(tutorialPages: [ToolScreenShareTutorialPageDomainModel]) -> Bool {
        return currentPage >= tutorialPages.count - 1
    }
    
    private func refreshContinueTitle(interfaceStrings: ToolScreenShareInterfaceStringsDomainModel, tutorialPages: [ToolScreenShareTutorialPageDomainModel]) {
        
        let isOnLastPage: Bool = getIsOnLastPage(tutorialPages: tutorialPages)
        
        continueTitle = !isOnLastPage ? interfaceStrings.nextTutorialPageActionTitle : interfaceStrings.shareLinkActionTitle
    }
    
    private func markToolScreenShareTutorialViewed() {
     
        ToolScreenShareTutorialViewModel.didViewToolScreenShareTutorialCancellable = didViewToolScreenShareTutorialUseCase
            .didViewPublisher(toolId: toolId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
    }
}

// MARK: - Inputs

extension ToolScreenShareTutorialViewModel {
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolScreenShareTutorial)
    }
    
    @objc func skipTapped() {
        
        markToolScreenShareTutorialViewed()
        
        flowDelegate?.navigate(step: .skipTappedFromToolScreenShareTutorial)
    }
    
    func continueTapped() {
        
        let isOnLastPage: Bool = getIsOnLastPage(tutorialPages: tutorialPages)
        
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
        
        markToolScreenShareTutorialViewed()
        
        flowDelegate?.navigate(step: .shareLinkTappedFromToolScreenShareTutorial)
    }
}
