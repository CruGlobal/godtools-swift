//
//  CardCollectionPageCard+MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import UIKit

extension CardCollectionPage.Card: MobileContentRenderableModel {
    
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
                
        let content = MultiplatformContent(
            content: content,
            contentInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
            itemSpacing: 10,
            scrollIsEnabled: true
        )
        
        return [content]
    }
}
