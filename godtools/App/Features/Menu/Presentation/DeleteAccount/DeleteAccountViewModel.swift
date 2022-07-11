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
    
    init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
    }
}

// MARK: - Inputs

extension DeleteAccountViewModel {
    
    func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromDeleteAccount)
    }
}
