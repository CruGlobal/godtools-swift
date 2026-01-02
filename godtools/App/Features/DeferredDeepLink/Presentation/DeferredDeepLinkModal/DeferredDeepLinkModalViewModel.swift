//
//  DeferredDeepLinkModalViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class DeferredDeepLinkModalViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDeferredDeepLinkModalInterfaceStringsUseCase: GetDeferredDeepLinkModalInterfaceStringsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let deepLinkingService: DeepLinkingService

    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var modalTitle: String = ""
    @Published var modalMessage: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDeferredDeepLinkModalInterfaceStringsUseCase: GetDeferredDeepLinkModalInterfaceStringsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, deepLinkingService: DeepLinkingService) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDeferredDeepLinkModalInterfaceStringsUseCase = getDeferredDeepLinkModalInterfaceStringsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.deepLinkingService = deepLinkingService
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getDeferredDeepLinkModalInterfaceStringsUseCase.getStringsPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] interfaceStrings in
                
                self?.modalTitle = interfaceStrings.title
                self?.modalMessage = interfaceStrings.message
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension DeferredDeepLinkModalViewModel {
    
    func closeButtonTapped() {
        flowDelegate?.navigate(step: .closeTappedFromDeferredDeepLinkModal)
    }
    
    func pasteButtonTapped(pastedString: String?) {
        guard let pastedString = pastedString,
              let url = URL(string: pastedString),
              let deepLink = deepLinkingService.parseDeepLink(
                incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        else {
            
            trackActionAnalyticsUseCase.trackAction(
                screenName: "Deferred DeepLink",
                actionName: AnalyticsConstants.ActionNames.deeplinkError,
                siteSection: "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                contentLanguageSecondary: nil,
                url: nil,
                data: nil)
  
            return
        }
                
        flowDelegate?.navigate(step: .handleDeepLinkFromDeferredDeepLinkModal(deepLinkType: deepLink))
    }
}
