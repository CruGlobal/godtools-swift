//
//  MultiplatformContentText.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentText: ContentTextModelType {
    
    private let contentText: Text
    
    required init(text: Text) {
     
        self.contentText = text
    }
    
    var endImage: String? {
        return contentText.endImage?.localName
    }
    
    var endImageSize: Int32 {
        return contentText.endImageSize
    }
    
    var startImage: String? {
        return contentText.startImage?.localName
    }
    
    var startImageSize: Int32 {
        return contentText.startImageSize
    }
    
    var text: String? {
        return contentText.text
    }
    
    var textStyle: String? {
        return nil // TODO: Implement. ~Levi
    }
    
    var textAlignment: MobileContentTextAlignment? {
       
        switch contentText.textAlign {
        case .start:
            return .left
    
        case .center:
            return .center
            
        case .end:
            return .right
            
        default:
            assertionFailure("Found unsupported Text.Align. Ensure all alignments are supported.")
            return .left
        }
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: contentText.textScale)
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: contentText.textColor)
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentText {
    
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
