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
    private let viewToolScreenShareQRCodeUseCase: ViewToolScreenShareQRCodeUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let shareUrl: String
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published var interfaceStrings: ToolScreenShareQRCodeInterfaceStringsDomainModel = .emptyStrings()
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewToolScreenShareQRCodeUseCase: ViewToolScreenShareQRCodeUseCase, shareUrl: String) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewToolScreenShareQRCodeUseCase = viewToolScreenShareQRCodeUseCase
        self.shareUrl = shareUrl
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                viewToolScreenShareQRCodeUseCase
                    .viewQRCodePublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] qrCodeDomainModel in
                
                self?.interfaceStrings = qrCodeDomainModel.interfaceStrings
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
        flowDelegate?.navigate(step: .closeTappedFromShareQRCode)
    }
}
