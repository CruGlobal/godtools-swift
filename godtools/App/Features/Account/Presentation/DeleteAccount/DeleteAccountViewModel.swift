//
//  DeleteAccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeleteAccountViewModel: ObservableObject {
        
    private weak var flowDelegate: FlowDelegate?
    
    let title: String
    let subtitle: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        
        title = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.DeleteAccount.title.rawValue)
        subtitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.DeleteAccount.subtitle.rawValue)
        confirmButtonTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.DeleteAccount.confirmButtonTitle.rawValue)
        cancelButtonTitle = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.DeleteAccount.cancelButtonTitle.rawValue)
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
