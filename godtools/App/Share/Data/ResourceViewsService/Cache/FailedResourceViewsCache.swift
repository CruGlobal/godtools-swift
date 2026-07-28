//
//  FailedResourceViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class FailedResourceViewsCache: Sendable {
    
    let persistence: any Persistence<ResourceViewDataModel, ResourceViewDataModel>
    
    init(persistence: any Persistence<ResourceViewDataModel, ResourceViewDataModel>) {
        
        self.persistence = persistence
    }
    
    func cacheFailedResourceViews(resourceViews: [ResourceViewDataModel]) async throws {
             
        guard !resourceViews.isEmpty else {
            return
        }
                
        var updateResourceViews: [ResourceViewDataModel] = Array()
        
        for resourceView in resourceViews {
                        
            let quantity: Int
            
            if let existingResourceView = try persistence.getDataModel(id: resourceView.id) {
                quantity = existingResourceView.quantity + 1
            }
            else {
                quantity = 1
            }
            
            updateResourceViews.append(
                resourceView.copy(quantity: quantity)
            )
        }
        
        _ = try await persistence.writeObjects(externalObjects: updateResourceViews, writeOption: nil, getOption: nil)
    }
}
