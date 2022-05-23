//
//  ToolSettingsShareablesViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import GodToolsToolParser

class ToolSettingsShareablesViewModel: BaseToolSettingsShareablesViewModel {
    
    private let shareables: [Shareable]
    private let manifestResourcesCache: ManifestResourcesCache
    
    required init(shareables: [Shareable], manifestResourcesCache: ManifestResourcesCache) {
        
        self.shareables = shareables
        self.manifestResourcesCache = manifestResourcesCache
        
        super.init()
        
        self.numberOfItems = shareables.count
    }
    
    override func getShareableItemViewModel(index: Int) -> BaseToolSettingsShareableItemViewModel {
        return ToolSettingsShareableItemViewModel(shareable: shareables[index], manifestResourcesCache: manifestResourcesCache)
    }
}
