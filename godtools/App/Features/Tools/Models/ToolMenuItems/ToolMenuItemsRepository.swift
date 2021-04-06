//
//  ToolMenuItemsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolMenuItemsRepository {
    
    private let cache: LocalToolMenuItemsCache
    
    required init(localizationServices: LocalizationServices) {
        
        cache = LocalToolMenuItemsCache(localizationServices: localizationServices)
    }
    
    func getToolMenuItems(completion: @escaping ((_ toolMenuItems: [ToolMenuItem]) -> Void)) {
        
        completion(cache.getToolMenuItems())
    }
}
