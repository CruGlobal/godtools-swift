//
//  ToolScreenShareQRCodeViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class ToolScreenShareQRCodeViewModel: ObservableObject {
    
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
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {
        
        strings = getToolScreenShareQRCodeStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension ToolScreenShareQRCodeViewModel {
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromShareToolScreenQRCode)
    }
}
