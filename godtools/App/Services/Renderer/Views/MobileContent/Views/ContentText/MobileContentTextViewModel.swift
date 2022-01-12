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
    
    private let textModel: ContentTextModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerModel: MobileContentRenderableModelContainer?
    private let fontService: FontService
    private let primaryLanguge: LanguageModel
    private let fontSize: CGFloat = 18
    private let defaultFontWeight: UIFont.Weight = .regular
        
    let textColor: UIColor
    
    required init(textModel: ContentTextModelType, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?, fontService: FontService, primaryLanguage: LanguageModel) {
        
        self.textModel = textModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
        self.fontService = fontService
        self.primaryLanguge = primaryLanguage
        
        let containerTextColor: UIColor?
        if containerModel is CardModelType {
            containerTextColor = rendererPageModel.pageColors.cardTextColor?.uiColor
        }
        else {
            containerTextColor = containerModel?.textColor?.uiColor
        }
        
        self.textColor = textModel.getTextColor()?.uiColor ?? containerTextColor ?? rendererPageModel.pageColors.textColor.uiColor
    }
    
    var startImage: UIImage? {
        
        guard let resource = textModel.startImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var startImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(textModel.startImageSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesStartImage: Bool {
        guard let resource = textModel.startImage else {
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
        return textModel.text
    }
    
    var textAlignment: NSTextAlignment {
        
        let textModelAlignment = textModel.textAlignment
        let containerModelAlignment = containerModel?.textAlignment
        
        //first determine the desired alignment for left-to-right languages
        var modelTextAlignment = textModelAlignment ?? containerModelAlignment
        
        //if primary language is right-to-left, flip the alignment
        if languageTextAlignment == .right {
            
            if modelTextAlignment == .left {
                
                modelTextAlignment = .right
            } else if modelTextAlignment == .right {
                
                modelTextAlignment = .left
            }
        }
        
        if let textAlignment = modelTextAlignment {
            
            switch textAlignment {
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
        
        guard let resource = textModel.endImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var endImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(textModel.endImageSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesEndImage: Bool {
        guard let resource = textModel.endImage else {
            return true
        }
        return resource.isEmpty
    }
    
    private func getFontWeight() -> UIFont.Weight {
        
        let fontWeight: UIFont.Weight
        
        let textStyles: [MobileContentTextStyle] = textModel.getTextStyles()
        
        // TODO: Need to add support for multiple textStyles. ~Levi
        if let textStyle = textStyles.first {
            
            if textStyle == .bold {
                fontWeight = .bold
            }
            else if textStyle == .italic {
                fontWeight = defaultFontWeight
            }
            else if textStyle == .underline {
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
        
        // TODO: Remove commented out code once XmlNodeRenderer is removed. ~Levi
        //let manifestTextScale: Double = rendererPageModel.manifest.attributes.textScale.doubleValue
        //let pageTextScale: Double = rendererPageModel.pageModel.textScale.doubleValue
        //let textScale: Double = textModel.textScale.doubleValue
        //fontScale = CGFloat(manifestTextScale * pageTextScale * textScale)
        
        fontScale = CGFloat(textModel.textScale.doubleValue)
        
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
        return rendererPageModel.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return []
    }
    
    var defaultAnalyticsEventsTrigger: MobileContentAnalyticsEventTrigger {
        return .visible
    }
}
