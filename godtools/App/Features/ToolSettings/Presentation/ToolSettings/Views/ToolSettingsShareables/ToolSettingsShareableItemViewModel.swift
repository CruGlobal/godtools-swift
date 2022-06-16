//
//  ToolSettingsShareableItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import GodToolsToolParser

class ToolSettingsShareableItemViewModel: ObservableObject {
    
    private let shareable: Shareable
    private let manifestResourcesCache: ManifestResourcesCache
    
    @Published var image: SwiftUI.Image = Image("")
    @Published var title: String = ""
    
    required init(shareable: Shareable, manifestResourcesCache: ManifestResourcesCache) {
        
        self.shareable = shareable
        self.manifestResourcesCache = manifestResourcesCache
                        
        if let shareableImage = shareable as? ShareableImage {
            
            self.title = shareableImage.description_?.text ?? ""
            
            if let resource = shareableImage.resource, let cachedImage = manifestResourcesCache.getImageFromManifestResources(resource: resource) {
                
                self.image = Image(uiImage: cachedImage)
            }
        }
    }
}
