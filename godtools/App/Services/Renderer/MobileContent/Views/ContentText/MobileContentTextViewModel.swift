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
    private let containerNode: MobileContentContainerNode?
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let defaultFontWeight: UIFont.Weight = .regular
    private let defaultImagePointSize: Float = 40
        
    let textColor: UIColor
    
    required init(textNode: ContentTextNode, pageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?, fontService: FontService) {
        
        self.textNode = textNode
        self.pageModel = pageModel
        self.containerNode = containerNode
        self.fontService = fontService
        
        let containerTextColor: UIColor?
        if containerNode is CardNode {
            containerTextColor = pageModel.pageColors.cardTextColor
        }
        else {
            containerTextColor = containerNode?.textColor?.color
        }
        
        self.textColor = textNode.getTextColor()?.color ?? containerTextColor ?? pageModel.pageColors.textColor
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
        
        return getScaledFont(
            fontSizeToScale: fontSize,
            fontWeightElseUseTextDefault: nil
        )
    }
    
    var text: String? {
        return textNode.text
    }
    
    var textAlignment: NSTextAlignment {
               
        let nodeTextAlignment: MobileContentTextAlign? = textNode.textAlignment ?? containerNode?.textAlignment
        
        if let nodeTextAlignment = nodeTextAlignment {
            
            switch nodeTextAlignment {
            case .left:
                return .left
            case .center:
                return .center
            case .right:
                return .right
            }
        }
        
        return languageTextAlignment
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
    
    private func getFontWeight() -> UIFont.Weight {
        
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
        
        return fontWeight
    }
    
    private func getFontScale() -> CGFloat {
        
        let fontScale: CGFloat
        
        if let textScaleString = textNode.textScale, !textScaleString.isEmpty, let number = MobileContentTextViewModel.numberFormatter.number(from: textScaleString) {
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
        return fontScale
    }
    
    func getScaledFont(fontSizeToScale: CGFloat, fontWeightElseUseTextDefault: UIFont.Weight?) -> UIFont {
                
        return fontService.getFont(
            size: fontSizeToScale * getFontScale(),
            weight: fontWeightElseUseTextDefault ?? getFontWeight()
        )
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentTextViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return pageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return []
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}
