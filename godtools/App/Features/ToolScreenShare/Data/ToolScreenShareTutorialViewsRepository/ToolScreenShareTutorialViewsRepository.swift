//
//  ToolScreenShareTutorialViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class ToolScreenShareTutorialViewsRepository {
    
    private let cache: ToolScreenShareTutorialViewsCache
    
    init(cache: ToolScreenShareTutorialViewsCache) {
        
        self.cache = cache
    }
    
    func getToolScreenShareTutorialView(id: String) -> ToolScreenShareTutorialViewDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    private func incrementNumberOfViews(id: String, incrementNumberOfViewsBy: Int) async throws {
        
        let updateToolScreenShare: ToolScreenShareTutorialViewDataModel
        let newNumberOfViews: Int
        
        let currentToolScreenShare: ToolScreenShareTutorialViewDataModel? = try cache.persistence.getDataModel(id: id)
        
        if let currentToolScreenShare = currentToolScreenShare {
            
            newNumberOfViews = currentToolScreenShare.numberOfViews + incrementNumberOfViewsBy
            
            updateToolScreenShare = currentToolScreenShare.copy(numberOfViews: newNumberOfViews)
        }
        else {
            
            newNumberOfViews = incrementNumberOfViewsBy
            
            updateToolScreenShare = ToolScreenShareTutorialViewDataModel(
                id: id,
                numberOfViews: newNumberOfViews
            )
        }
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [updateToolScreenShare],
            writeOption: nil,
            getOption: nil
        )
    }
    
    func incrementNumberOfViewsPublisher(id: String, incrementNumberOfViewsBy: Int = 1) -> AnyPublisher<Void, Error> {
        return AnyPublisher() {
            try await self.incrementNumberOfViews(id: id, incrementNumberOfViewsBy: incrementNumberOfViewsBy)
        }
    }
}
