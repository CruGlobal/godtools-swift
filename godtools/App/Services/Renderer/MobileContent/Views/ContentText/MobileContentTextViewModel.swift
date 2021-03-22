//
//  MobileContentTextViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTextViewModel: MobileContentTextViewModelType {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let textNode: ContentTextNode
    private let pageModel: MobileContentRendererPageModel
    private let fontService: FontService
    private let fontSize: CGFloat
    private let defaultFontWeight: UIFont.Weight
    private let defaultTextAlignment: NSTextAlignment
    private let defaultImagePointSize: Float = 40
    
    let textColor: UIColor
    
    required init(textNode: ContentTextNode, pageModel: MobileContentRendererPageModel, fontService: FontService, fontSize: CGFloat, defaultFontWeight: UIFont.Weight, defaultTextAlignment: NSTextAlignment, textColor: UIColor) {
        
        self.textNode = textNode
        self.pageModel = pageModel
        self.fontService = fontService
        self.fontSize = fontSize
        self.defaultFontWeight = defaultFontWeight
        self.defaultTextAlignment = defaultTextAlignment
        self.textColor = textColor
    }
    
    var startImage: UIImage? {
        
        guard let resource = textNode.startImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = pageModel.resourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var startImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(Float(textNode.startImageSize) ?? defaultImagePointSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesStartImage: Bool {
        guard let resource = textNode.startImage else {
            return true
        }
        return resource.isEmpty
    }
    
    var font: UIFont {
        
        let fontScale: CGFloat
        
        if let textScaleString = textNode.textScale,
            !textScaleString.isEmpty,
            let number = MobileContentTextViewModel.numberFormatter.number(from: textScaleString) {
            
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
        let fontWeight: UIFont.Weight
        
        if let textStyle = textNode.textStyle, !textStyle.isEmpty {
            if textStyle == "bold" {
                fontWeight = .bold
            }
            else if textStyle == "italic" {
                fontWeight = defaultFontWeight
            }
            else if textStyle == "underline" {
                fontWeight = defaultFontWeight
            }
            else {
                fontWeight = defaultFontWeight
            }
        }
        else {
            fontWeight = defaultFontWeight
        }
        
        return fontService.getFont(size: fontSize * fontScale, weight: fontWeight)
    }
    
    var text: String? {
        return textNode.text
    }
    
    var textAlignment: NSTextAlignment {
        
        let textAlignment: NSTextAlignment
        
        if let textAlign = textNode.textAlign, !textAlign.isEmpty {
            if textAlign == "left" {
                textAlignment = .left
            }
            else if textAlign == "center" {
                textAlignment = .center
            }
            else if textAlign == "end" {
                textAlignment = .right
            }
            else {
                textAlignment = defaultTextAlignment
            }
        }
        else {
            textAlignment = defaultTextAlignment
        }
        
        return textAlignment
    }
    
    var endImage: UIImage? {
        
        guard let resource = textNode.endImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = pageModel.resourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var endImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(Float(textNode.endImageSize) ?? defaultImagePointSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesEndImage: Bool {
        guard let resource = textNode.endImage else {
            return true
        }
        return resource.isEmpty
    }
}
