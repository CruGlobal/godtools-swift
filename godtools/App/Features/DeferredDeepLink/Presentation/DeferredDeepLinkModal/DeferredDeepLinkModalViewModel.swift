//
//  DeferredDeepLinkModalViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class DeferredDeepLinkModalViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase

    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
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
    
    func pasteButtonTapped() {
        
    }
    
    func cancelButtonTapped() {
        flowDelegate?.navigate(step: .cancelTappedFromDeferredDeepLinkModal)
    }
}
