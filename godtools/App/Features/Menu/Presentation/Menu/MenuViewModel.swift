//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class MenuViewModel: ObservableObject {
    
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        
        navTitle = localizationServices.stringForMainBundle(key: "settings")
    }
}

// MARK: - Inputs

extension MenuViewModel {
    
    @objc func doneTapped() {
        
        flowDelegate?.navigate(step: .doneTappedFromMenu)
    }
}
