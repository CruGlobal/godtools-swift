//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MenuViewModel: ObservableObject {
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
    }
}

// MARK: - Inputs

extension MenuViewModel {
    
    @objc func doneTapped() {
        
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
}
