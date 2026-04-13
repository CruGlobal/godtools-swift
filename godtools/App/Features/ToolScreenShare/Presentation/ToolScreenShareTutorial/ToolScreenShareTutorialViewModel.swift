//
//  ToolScreenShareTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class ToolScreenShareTutorialViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
        
    private let toolId: String
    private let showTutorialPages: ShowToolScreenShareTutorialPages
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolScreenShareTutorialStringsUseCase: GetToolScreenShareTutorialStringsUseCase
    private let getToolScreenShareTutorialUseCase: GetToolScreenShareTutorialUseCase
    private let didViewToolScreenShareTutorialUseCase: DidViewToolScreenShareTutorialUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var didMarkTutorialAsViewed: Bool = false
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = ToolScreenShareTutorialStringsDomainModel.emptyValue
    @Published private(set) var shareOptions: [ToolScreenShareTutorialShareOption] = []
    @Published private(set) var hidesSkipButton: Bool = false
    @Published private(set) var hidesContinueButton: Bool = false
    @Published private(set) var tutorialPages: [ToolScreenShareTutorialPageDomainModel] = Array()
    
    @Published var currentPage: Int = 0
    
    init(flowDelegate: FlowDelegate, toolId: String, showTutorialPages: ShowToolScreenShareTutorialPages, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolScreenShareTutorialStringsUseCase: GetToolScreenShareTutorialStringsUseCase, getToolScreenShareTutorialUseCase: GetToolScreenShareTutorialUseCase, didViewToolScreenShareTutorialUseCase: DidViewToolScreenShareTutorialUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.showTutorialPages = showTutorialPages
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolScreenShareTutorialStringsUseCase = getToolScreenShareTutorialStringsUseCase
        self.getToolScreenShareTutorialUseCase = getToolScreenShareTutorialUseCase
        self.didViewToolScreenShareTutorialUseCase = didViewToolScreenShareTutorialUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getToolScreenShareTutorialStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ToolScreenShareTutorialStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getToolScreenShareTutorialUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (pages: [ToolScreenShareTutorialPageDomainModel]) in
                                
                let tutorialPages: [ToolScreenShareTutorialPageDomainModel]
                
                switch showTutorialPages {
                
                case .lastPageWithQRCodeOption:
                   
                    if let lastPage = pages.last {
                        tutorialPages = [lastPage]
                    }
                    else {
                        tutorialPages = pages
                    }
                    
                default:
                    tutorialPages = pages
                }
                
                self?.tutorialPages = tutorialPages
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
            
            let isOnLastPage: Bool = weakSelf.getIsOnLastPage(tutorialPages: tutorialPages)
            
            if isOnLastPage {
                weakSelf.markToolScreenShareTutorialViewed()
            }
            
            weakSelf.hidesSkipButton = isOnLastPage
            weakSelf.hidesContinueButton = isOnLastPage
            
            weakSelf.shareOptions = isOnLastPage ? [.qrCode, .shareLink] : []
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
    
    private func markToolScreenShareTutorialViewed() {
     
        guard showTutorialPages == .allPages && !didMarkTutorialAsViewed else {
            return
        }
        
        didMarkTutorialAsViewed = true
        
        didViewToolScreenShareTutorialUseCase
            .execute(toolId: toolId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
}

// MARK: - Inputs

extension ToolScreenShareTutorialViewModel {
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolScreenShareTutorial)
    }
    
    @objc func skipTapped() {
        
        guard tutorialPages.count > 0 else {
            return
        }
        
        let lastPage: Int = tutorialPages.count - 1
        currentPage = lastPage
    }

    func continueTapped() {
        nextPageTapped()
    }
    
    func generateQRCodeTapped() {
        flowDelegate?.navigate(step: .generateQRCodeTappedFromToolScreenShareTutorial)
    }
    
    func shareLinkTapped() {
        flowDelegate?.navigate(step: .shareLinkTappedFromToolScreenShareTutorial)
    }
    
    private func nextPageTapped() {
        currentPage += 1
    }
}
