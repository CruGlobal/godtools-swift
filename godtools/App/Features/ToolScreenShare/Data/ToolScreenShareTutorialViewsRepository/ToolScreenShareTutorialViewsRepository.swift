//
//  ToolScreenShareTutorialViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolScreenShareTutorialViewsRepository {
    
    private let cache: RealmToolScreenShareTutorialViewsCache
    
    init(cache: RealmToolScreenShareTutorialViewsCache) {
        
        self.cache = cache
    }
    
    func getToolScreenShareTutorialViewPublisher(id: String) -> AnyPublisher<ToolScreenShareTutorialViewDataModel?, Never> {
        
        let cachedToolScreenShareView = cache.getToolScreenShareView(id: id)
        
        return Just(cachedToolScreenShareView)
            .eraseToAnyPublisher()
    }
    
    func incrementNumberOfViewsPublisher(id: String, incrementNumberOfViewsBy: Int) -> AnyPublisher<Void, Error> {
        
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
