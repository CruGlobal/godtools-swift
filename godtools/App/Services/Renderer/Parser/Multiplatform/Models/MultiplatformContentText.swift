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
    
    var textAlignment: Text.Align {
        return contentText.textAlign
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: contentText.textScale)
    }
    
    var minimumLines: Int32 {
        return contentText.minimumLines
    }
    
    func getTextColor() -> UIColor {
        return contentText.textColor
    }
    
    func getTextColor() -> MobileContentColor? {
        return MobileContentColor(color: contentText.textColor)
    }
    
    func getTextStyles() -> [Text.Style] {
        return Array(contentText.textStyles)
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
