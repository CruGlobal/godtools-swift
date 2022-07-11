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
    
    @Published var deleteOktaAccountInstructions: String = ""
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        
        deleteOktaAccountInstructions = localizationServices.stringForMainBundle(key: "deleteAccount.deleteOktaAccountInstructions")
    }
}

// MARK: - Inputs

extension DeleteAccountViewModel {
    
    func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromDeleteAccount)
    }
}
