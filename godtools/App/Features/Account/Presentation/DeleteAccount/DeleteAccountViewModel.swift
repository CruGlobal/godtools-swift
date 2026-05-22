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
   
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDeleteAccountStringsUseCase: GetDeleteAccountStringsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = DeleteAccountStringsDomainModel.emptyValue
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDeleteAccountStringsUseCase: GetDeleteAccountStringsUseCase) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDeleteAccountStringsUseCase = getDeleteAccountStringsUseCase
        self.flowDelegate = flowDelegate
        
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
        
        flowDelegate?.navigate(step: .closeTappedFromDeleteAccount)
    }
    
    func deleteAccountTapped() {
        
        flowDelegate?.navigate(step: .deleteAccountTappedFromDeleteAccount)
    }
    
    func cancelTapped() {
        
        flowDelegate?.navigate(step: .cancelTappedFromDeleteAccount)
    }
}
