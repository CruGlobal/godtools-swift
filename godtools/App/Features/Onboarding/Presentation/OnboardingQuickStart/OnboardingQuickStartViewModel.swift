//
//  OnboardingQuickStartViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class OnboardingQuickStartViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getOnboardingQuickStartInterfaceStringsUseCase: GetOnboardingQuickStartInterfaceStringsUseCase
    private let getOnboardingQuickStartLinksUseCase: GetOnboardingQuickStartLinksUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var interfaceStrings: OnboardingQuickStartInterfaceStringsDomainModel?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = ""
    
    @Published var title: String = ""
    @Published var quickStartLinks: [OnboardingQuickStartLinkDomainModel] = Array()
    @Published var endTutorialButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getOnboardingQuickStartInterfaceStringsUseCase: GetOnboardingQuickStartInterfaceStringsUseCase, getOnboardingQuickStartLinksUseCase: GetOnboardingQuickStartLinksUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getOnboardingQuickStartInterfaceStringsUseCase = getOnboardingQuickStartInterfaceStringsUseCase
        self.getOnboardingQuickStartLinksUseCase = getOnboardingQuickStartLinksUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        getOnboardingQuickStartInterfaceStringsUseCase
            .getStringsPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: OnboardingQuickStartInterfaceStringsDomainModel) in
                
                self?.interfaceStrings = interfaceStrings
                self?.title = interfaceStrings.title
                self?.endTutorialButtonTitle = interfaceStrings.getStartedButtonTitle
            }
            .store(in: &cancellables)
        
        getOnboardingQuickStartLinksUseCase
            .getLinksPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$quickStartLinks)
    }
    
    private var analyticsScreenName: String {
        return "onboarding-quick-start"
    }
}

// MARK: - Inputs

extension OnboardingQuickStartViewModel {
    
    func quickStartLinkTapped(link: OnboardingQuickStartLinkDomainModel) {
                
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: link.analyticsEventActionName,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
        
        let linkFlowStep: FlowStep
        
        switch link.linkType {
            
        case .chooseOneOfOurTools:
            linkFlowStep = .chooseToolTappedFromOnboardingQuickStart
            
        case .readOurArticles:
            linkFlowStep = .readArticlesTappedFromOnboardingQuickStart
            
        case .tryOurLessons:
            linkFlowStep = .tryLessonsTappedFromOnboardingQuickStart
        }
        
        flowDelegate?.navigate(step: linkFlowStep)
    }
    
    @objc func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingQuickStart)
    }
    
    func endTutorialTapped() {
        
        flowDelegate?.navigate(step: .endTutorialFromOnboardingQuickStart)
    }
}
