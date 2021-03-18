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
    
    private let contentTextNode: ContentTextNode
    private let manifestResourcesCache: ManifestResourcesCache
    private let fontService: FontService
    private let fontSize: CGFloat
    private let defaultFontWeight: UIFont.Weight
    private let defaultTextAlignment: NSTextAlignment
    private let defaultImagePointSize: Float = 40
    
    let textColor: UIColor
    
    required init(contentTextNode: ContentTextNode, manifestResourcesCache: ManifestResourcesCache, fontService: FontService, fontSize: CGFloat, defaultFontWeight: UIFont.Weight, defaultTextAlignment: NSTextAlignment, textColor: UIColor) {
        
        self.contentTextNode = contentTextNode
        self.manifestResourcesCache = manifestResourcesCache
        self.fontService = fontService
        self.fontSize = fontSize
        self.defaultFontWeight = defaultFontWeight
        self.defaultTextAlignment = defaultTextAlignment
        self.textColor = textColor
    }
    
    var startImage: UIImage? {
        
        guard let resource = contentTextNode.startImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = manifestResourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var startImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(Float(contentTextNode.startImageSize) ?? defaultImagePointSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesStartImage: Bool {
        guard let resource = contentTextNode.startImage else {
            return true
        }
        return resource.isEmpty
    }
    
    var font: UIFont {
        
        let fontScale: CGFloat
        
        if let textScaleString = contentTextNode.textScale,
            !textScaleString.isEmpty,
            let number = MobileContentTextViewModel.numberFormatter.number(from: textScaleString) {
            
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
        let fontWeight: UIFont.Weight
        
        if let textStyle = contentTextNode.textStyle, !textStyle.isEmpty {
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
        return contentTextNode.text
    }
    
    var textAlignment: NSTextAlignment {
        
        let textAlignment: NSTextAlignment
        
        if let textAlign = contentTextNode.textAlign, !textAlign.isEmpty {
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
        
        guard let resource = contentTextNode.endImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = manifestResourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var endImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(Float(contentTextNode.endImageSize) ?? defaultImagePointSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesEndImage: Bool {
        guard let resource = contentTextNode.endImage else {
            return true
        }
        return resource.isEmpty
    }
}
