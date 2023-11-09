//
//  CreatingToolScreenShareSessionTimedOutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class CreatingToolScreenShareSessionTimedOutViewModel: AlertMessageViewModelType {
        
    private var cancellables = Set<AnyCancellable>()
    
    let title: String? = nil
    let message: String? = nil
    let cancelTitle: String? = nil
    let acceptTitle: String = ""
    
    init(domainModel: CreatingToolScreenShareSessionTimedOutDomainModel) {
        
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionTimedOutViewModel {
    
    func acceptTapped() {
        
    }
}
