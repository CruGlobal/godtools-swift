//
//  DeleteAccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class DeleteAccountViewModel: ObservableObject {
   
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDeleteAccountStringsUseCase: GetDeleteAccountStringsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = DeleteAccountStringsDomainModel.emptyValue
    
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getDeleteAccountStringsUseCase: GetDeleteAccountStringsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDeleteAccountStringsUseCase = getDeleteAccountStringsUseCase
        
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
        
        strings = getDeleteAccountStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension DeleteAccountViewModel {
    
    @objc func closeTapped() {
        
        stepEmitter.emit(step: AppFlowStep.closeTappedFromDeleteAccount)
    }
    
    func deleteAccountTapped() {
        
        stepEmitter.emit(step: AppFlowStep.deleteAccountTappedFromDeleteAccount)
    }
    
    func cancelTapped() {
        
        stepEmitter.emit(step: AppFlowStep.cancelTappedFromDeleteAccount)
    }
}
