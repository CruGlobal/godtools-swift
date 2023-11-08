//
//  CreatingToolScreenShareSessionTimedOutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class CreatingToolScreenShareSessionTimedOutViewModel: AlertMessageViewModelType {
    
    let title: String? = nil
    let message: String? = nil
    let cancelTitle: String? = nil
    let acceptTitle: String = ""
    
    init() {
        
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionTimedOutViewModel {
    
    func acceptTapped() {
        
    }
}
