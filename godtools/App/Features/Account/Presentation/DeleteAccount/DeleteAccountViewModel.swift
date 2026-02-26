//
//  DeleteAccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class DeleteAccountViewModel: ObservableObject {
   
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = DeleteAccountStringsDomainModel.emptyValue
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguage: GetCurrentAppLanguageUseCase, getDeleteAccountStringsUseCase: GetDeleteAccountStringsUseCase) {
        
        self.flowDelegate = flowDelegate
        
        getCurrentAppLanguage
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getDeleteAccountStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: DeleteAccountStringsDomainModel) in
                self?.strings = strings
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
