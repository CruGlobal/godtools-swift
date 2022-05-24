//
//  ToolSettingsShareablesViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation
import GodToolsToolParser
import UIKit

class ToolSettingsShareablesViewModel: BaseToolSettingsShareablesViewModel {
    
    private let shareables: [Shareable]
    private let manifestResourcesCache: ManifestResourcesCache
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, shareables: [Shareable], manifestResourcesCache: ManifestResourcesCache) {
        
        self.flowDelegate = flowDelegate
        self.shareables = shareables
        self.manifestResourcesCache = manifestResourcesCache
        
        super.init()
        
        self.numberOfItems = shareables.count
    }
    
    override func getShareableItemViewModel(index: Int) -> BaseToolSettingsShareableItemViewModel {
        return ToolSettingsShareableItemViewModel(shareable: shareables[index], manifestResourcesCache: manifestResourcesCache)
    }
    
    override func shareableTapped(index: Int) {
        
        let shareable: Shareable = shareables[index]
        
        guard let shareableImage = shareable as? ShareableImage, let resource = shareableImage.resource, let imageToShare = manifestResourcesCache.getImageFromManifestResources(resource: resource) else {
            return
        }
        
        flowDelegate?.navigate(step: .shareableTappedFromToolSettings(shareable: shareable, shareImage: imageToShare))
    }
}
