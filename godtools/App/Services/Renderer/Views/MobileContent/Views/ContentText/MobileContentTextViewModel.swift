//
//  MobileContentTextViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentTextViewModel: MobileContentTextViewModelType {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let textModel: Text
    private let renderedPageContext: MobileContentRenderedPageContext
    private let fontService: FontService
    private let fontSize: CGFloat = 18
        
    let textColor: UIColor
    
    required init(textModel: Text, renderedPageContext: MobileContentRenderedPageContext, fontService: FontService) {
        
        self.textModel = textModel
        self.renderedPageContext = renderedPageContext
        self.fontService = fontService
        
        self.textColor = textModel.textColor
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
        
        if language.languageDirection == .rightToLeft {
            
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
                
        return fontService.getFont(
            size: fontSizeToScale * getFontScale(),
            weight: fontWeightElseUseTextDefault ?? getFontWeight()
        )
    }
}

// MARK: - MobileContentViewModelType

extension MobileContentTextViewModel: MobileContentViewModelType {
    
    var language: LanguageModel {
        return renderedPageContext.language
    }
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return []
    }
}
