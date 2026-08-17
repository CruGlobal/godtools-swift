//
//  DeferredDeepLinkModalViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class DeferredDeepLinkModalViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDeferredDeepLinkModalStringsUseCase: GetDeferredDeepLinkModalStringsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let deepLinkingService: DeepLinkingService

    private var cancellables: Set<AnyCancellable> = Set()
            
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = DeferredDeepLinkModalStringsDomainModel.emptyValue
    
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getDeferredDeepLinkModalStringsUseCase: GetDeferredDeepLinkModalStringsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        deepLinkingService: DeepLinkingService
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDeferredDeepLinkModalStringsUseCase = getDeferredDeepLinkModalStringsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.deepLinkingService = deepLinkingService
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getDeferredDeepLinkModalStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension DeferredDeepLinkModalViewModel {
    
    func closeButtonTapped() {
        stepEmitter.emit(step: AppFlowStep.closeTappedFromDeferredDeepLinkModal)
    }
    
    func pasteButtonTapped(pastedString: String?) {
        guard let pastedString = pastedString,
              let url = URL(string: pastedString),
              let deepLink = deepLinkingService.parseDeepLink(
                incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        else {
            
            Task {
                await trackActionAnalyticsUseCase.execute(
                    properties: AnalyticsProperties(
                        screenName: "Deferred DeepLink",
                        siteSection: "",
                        siteSubSection: "",
                        appLanguage: nil,
                        contentLanguage: nil,
                        secondaryContentLanguage: nil
                    ),
                    actionName: AnalyticsConstants.ActionNames.deeplinkError,
                    data: nil)
            }
  
            return
        }
                
        stepEmitter.emit(step: AppFlowStep.handleDeepLinkFromDeferredDeepLinkModal(deepLinkType: deepLink))
    }
}
