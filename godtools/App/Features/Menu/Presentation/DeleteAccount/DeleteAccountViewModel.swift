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
        
        title = localizationServices.stringForMainBundle(key: MenuStringKeys.DeleteAccount.title.rawValue)
        subtitle = localizationServices.stringForMainBundle(key: MenuStringKeys.DeleteAccount.subtitle.rawValue)
        confirmButtonTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.DeleteAccount.confirmButtonTitle.rawValue)
        cancelButtonTitle = localizationServices.stringForMainBundle(key: MenuStringKeys.DeleteAccount.cancelButtonTitle.rawValue)
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
