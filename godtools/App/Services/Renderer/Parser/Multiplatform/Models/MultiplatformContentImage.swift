//
//  MultiplatformContentImage.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentImage: ContentImageModelType {
    
    private let image: Image
    
    required init(image: Image) {
        
        self.image = image
    }
    
    var events: [String] {
        return image.events.map({$0.description()})
    }
    
    var resource: String? {
        let fileName: String? = image.resource?.name
        return fileName
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentImage {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
