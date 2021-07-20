//
//  MultiplatformText.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformText: ContentTextModelType {
    
    private let contentText: Text
    
    required init(text: Text) {
     
        self.contentText = text
    }
    
    var endImage: String? {
        return nil // TODO: Implement. ~Levi
    }
    
    var endImageSize: String {
        return "" // TODO: Implement. ~Levi
    }
    
    var startImage: String? {
        return nil // TODO: Implement. ~Levi
    }
    
    var startImageSize: String {
        return "" // TODO: Implement. ~Levi
    }
    
    var text: String? {
        return contentText.text
    }
    
    var textStyle: String? {
        return nil // TODO: Implement. ~Levi
    }
    
    var textAlignment: MobileContentTextAlignment? {
        return nil // TODO: Implement. ~Levi
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: contentText.textScale)
    }
    
    func getTextColor() -> MobileContentColor? {
        return nil // TODO: Implement. ~Levi
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformText {
    
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
