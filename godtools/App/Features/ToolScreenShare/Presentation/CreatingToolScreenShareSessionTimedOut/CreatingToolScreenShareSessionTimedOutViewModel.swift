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
    
    let title: String?
    let message: String?
    let cancelTitle: String? = nil
    let acceptTitle: String
    
    init(domainModel: CreatingToolScreenShareSessionTimedOutDomainModel) {
        
        let interfaceStrings: CreatingToolScreenShareSessionTimedOutInterfaceStringsDomainModel = domainModel.interfaceStrings
        
        title = interfaceStrings.title
        message = interfaceStrings.message
        acceptTitle = interfaceStrings.acceptActionTitle
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionTimedOutViewModel {
    
    func acceptTapped() {
        
        // Nothing to here, but implementing for protocol AlertMessageViewModelType. ~Levi
    }
}
