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
    
    func toggleToolFavorited(tool: ToolDomainModel) {
        
        if getToolIsFavoritedUseCase.getToolIsFavorited(id: tool.dataModelId) {
            
            removeToolFromFavoritesUseCase.removeToolFromFavorites(id: tool.dataModelId)
            
        } else {
            
            addToolToFavoritesUseCase.addToolToFavorites(id: tool.dataModelId)
        }
    }
}
