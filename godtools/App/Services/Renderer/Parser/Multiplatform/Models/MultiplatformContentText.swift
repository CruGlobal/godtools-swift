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
        return contentText.endImage?.name
    }
    
    var endImageSize: Int32 {
        return contentText.endImageSize
    }
    
    var startImage: String? {
        return contentText.startImage?.name
    }
    
    var startImageSize: Int32 {
        return contentText.startImageSize
    }
    
    var text: String? {
        return contentText.text
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
    
    func getTextColor() -> UIColor {
        return contentText.textColor
    }
    
    func getTextStyles() -> [MobileContentTextStyle] {
       
        return contentText.textStyles.compactMap({
            
            let textStyle: MobileContentTextStyle?
            
            switch $0 {
            
            case .bold:
                textStyle = .bold
            
            case .italic:
                textStyle = .italic
            
            case .underline:
                textStyle = .underline
            
            default:
                assertionFailure("Found unsupported textStyle \($0). Ensure all textStyles are supported.")
                textStyle = nil
            }
            
            return textStyle
        })
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
