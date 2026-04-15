//
//  ToolScreenShareQRCodeViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class ToolScreenShareQRCodeViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolScreenShareQRCodeStringsUseCase: GetToolScreenShareQRCodeStringsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let shareUrl: String
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = ToolScreenShareQRCodeStringsDomainModel.emptyValue
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolScreenShareQRCodeStringsUseCase: GetToolScreenShareQRCodeStringsUseCase, shareUrl: String) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolScreenShareQRCodeStringsUseCase = getToolScreenShareQRCodeStringsUseCase
        self.shareUrl = shareUrl
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                getToolScreenShareQRCodeStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ToolScreenShareQRCodeStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ToolScreenShareQRCodeViewModel {
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromShareToolScreenQRCode)
    }
}
