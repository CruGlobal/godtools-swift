//
//  MultiplatformContentFactory.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentFactory {
    
    required init() {
        
    }
    
    static func getRenderableModel(content: Content) -> MobileContentRenderableModel? {
        
        let renderableModel: MobileContentRenderableModel?
        
        if let text = content as? Text {
            renderableModel = MultiplatformText(text: text)
        }
        else {
            renderableModel = nil
        }
        
        return renderableModel
    }
}
