//
//  MobileContentTextViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentTextViewModel: MobileContentViewModel {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let textModel: Text
    private let fontSize: CGFloat = 18
        
    let textColor: UIColor
    
    init(textModel: Text, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.textModel = textModel
        
        self.textColor = textModel.textColor
        
        super.init(baseModel: textModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var startImage: UIImage? {
        
        guard let resource = textModel.startImage else {
            return nil
        }
        
        guard let resourceImage = renderedPageContext.resourcesCache.getUIImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var startImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(textModel.startImageSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesStartImage: Bool {
        return textModel.startImage == nil
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
                
        return mapTextAlignToTextAlignment(textAlign: getLanguageTextAlign())
    }
    
    var minimumLines: CGFloat {
        return CGFloat(textModel.minimumLines)
    }
    
    var endImage: UIImage? {
        
        guard let resource = textModel.endImage else {
            return nil
        }
        
        guard let resourceImage = renderedPageContext.resourcesCache.getUIImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var endImageSize: CGSize {
        let floatValue: CGFloat = CGFloat(textModel.endImageSize)
        return CGSize(width: floatValue, height: floatValue)
    }
    
    var hidesEndImage: Bool {
        return textModel.endImage == nil
    }
    
    var shouldUnderlineText: Bool {
        return textModel.textStyles.contains(.underline)
    }
        
    private func getLanguageTextAlign() -> Text.Align {
        
        if renderedPageContext.language.direction == .rightToLeft {
            
            if textModel.textAlign == .start {
                return .end
            }
            else if textModel.textAlign == .end {
                return .start
            }
        }
        
        return textModel.textAlign
    }
    
    private func mapTextAlignToTextAlignment(textAlign: Text.Align) -> NSTextAlignment {
        
        switch textAlign {
        case .start:
            return .left
        case .center:
            return .center
        case .end:
            return .right
        default:
            return .left
        }
    }
    
    private func getFontWeight() -> UIFont.Weight {
             
        let textStyles: Set<Text.Style> = textModel.textStyles
        
        if textStyles.contains(.bold) {
            return .bold
        }
        
        return .regular
    }
    
    private func getFontScale() -> CGFloat {
                
        let fontScale = CGFloat(textModel.textScale)
                        
        return fontScale
    }
    
    func getScaledFont(fontSizeToScale: CGFloat, fontWeightElseUseTextDefault: UIFont.Weight?) -> UIFont {
                
        return FontLibrary.systemUIFont(size: fontSizeToScale * getFontScale(), weight: fontWeightElseUseTextDefault ?? getFontWeight())
    }
}
