//
//  ToolScreenShareViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolScreenShareViewsRepository {
    
    private let cache: RealmToolScreenShareViewsCache
    
    init(cache: RealmToolScreenShareViewsCache) {
        
        self.cache = cache
    }
    
    func getToolScreenShareViewPublisher(id: String) -> AnyPublisher<ToolScreenShareViewDataModel?, Never> {
        
        let cachedToolScreenShareView = cache.getToolScreenShareView(id: id)
        
        return Just(cachedToolScreenShareView)
            .eraseToAnyPublisher()
    }
    
    func incrementToolScreenShareViewPublisher(id: String, incrementNumberOfViewsBy: Int) -> AnyPublisher<Void, Error> {
        
        let currentNumberOfViews: Int
        
        if let existingToolScreenShareView = cache.getToolScreenShareView(id: id) {
            currentNumberOfViews = existingToolScreenShareView.numberOfViews
        }
        else {
            currentNumberOfViews = 0
        }
        
        let newNumberOfViews: Int = currentNumberOfViews + incrementNumberOfViewsBy
        
        let error: Error? = cache.setToolScreenShareNumberOfViews(id: id, numberOfViews: newNumberOfViews)
        
        if let error = error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        else {
            return Just(Void()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
