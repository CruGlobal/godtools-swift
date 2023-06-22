//
//  ToggleToolFavoritedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToggleToolFavoritedUseCase {
    
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let addToolToFavoritesUseCase: AddToolToFavoritesUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    
    init(getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, addToolToFavoritesUseCase: AddToolToFavoritesUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase) {
        
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.addToolToFavoritesUseCase = addToolToFavoritesUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
    }
    
    func toggleToolFavorited(tool: ResourceModel) {
        
        if getToolIsFavoritedUseCase.getToolIsFavorited(toolId: tool.id) {
            
            removeToolFromFavoritesUseCase.removeToolFromFavorites(resourceId: tool.id)
            
        } else {
            
            addToolToFavoritesUseCase.addToolToFavorites(resourceId: tool.id)
        }
    }
}
