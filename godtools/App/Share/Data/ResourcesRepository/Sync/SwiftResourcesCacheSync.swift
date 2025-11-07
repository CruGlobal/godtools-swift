//
//  SwiftResourcesCacheSync.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@available(iOS 17, *)
class SwiftResourcesCacheSync {
    
    init() {
        
    }
    
    func syncResources(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
     
        return Just(ResourcesCacheSyncResult.emptyResult())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
