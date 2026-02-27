//
//  DeferredDeepLinkModalStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct DeferredDeepLinkModalStringsDomainModel: Sendable {
    
    let title: String
    let message: String
    
    static var emptyValue: DeferredDeepLinkModalStringsDomainModel {
        return DeferredDeepLinkModalStringsDomainModel(title: "", message: "")
    }
}
