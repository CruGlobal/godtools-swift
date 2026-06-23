//
//  ShareToolQRCodeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class ShareToolQRCodeViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let getShareToolQRCodeStringsUseCase: GetShareToolQRCodeStringsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = ShareToolQRCodeStringsDomainModel.emptyValue
    @Published private(set) var shareToolQrCode: ShareToolQRCodeDomainModel?
    
    let shareUrl: String
    
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getShareToolQRCodeStringsUseCase: GetShareToolQRCodeStringsUseCase,
        shareUrl: String
    ) {
        
        self.stepEmitter = stepEmitter
        self.getShareToolQRCodeStringsUseCase = getShareToolQRCodeStringsUseCase
        self.shareUrl = shareUrl
        
        getCurrentAppLanguageUseCase
            .execute()
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getShareToolQRCodeStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ShareToolQRCodeStringsDomainModel) in
                       
                self?.strings = strings
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension ShareToolQRCodeViewModel {
    
    func closeTapped() {
        stepEmitter.emit(step: AppFlowStep.closedTappedFromShareToolQrCode)
    }
}
