//
//  ToolPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 11/4/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewFactory {
    
    static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let fontService: FontService
    
    required init(fontService: FontService) {
        
        self.fontService = fontService
    }
    
    // MARK: - ContentButtonNode
    
    func getContentButtonNodeButton(buttonNode: ContentButtonNode, fontSize: CGFloat, fontWeight: UIFont.Weight, buttonColor: UIColor, titleColor: UIColor) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        
        button.backgroundColor = buttonColor
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(buttonNode.textNode?.text, for: .normal)
        
        return button
    }
    
    // MARK: - ContentImageNode
    
    func getContentImageNodeImage(imageNode: ContentImageNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache) -> UIImageView? {
        
        guard imageNode.restrictToType == .mobile || imageNode.restrictToType == .noRestriction else {
            return nil
        }
        
        guard let resource = imageNode.resource else {
            return nil
        }
        
        guard let resourceSrc = manifest.resources[resource]?.src else {
            return nil
        }
        
        guard let resourceImage = translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: resourceSrc)) else {
            return nil
        }
        
        let imageView: UIImageView = UIImageView()
        imageView.image = resourceImage
        
        return imageView
    }
    
    // MARK: - ContentTextNode
    
    func getContentTextNodeLabel(textNode: ContentTextNode, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
        
        let label: UILabel = UILabel()
        
        styleContentTextNodeLabel(
            textNode: textNode,
            label: label,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textColor: textColor
        )
        
        return label
    }
    
    func styleContentTextNodeLabel(textNode: ContentTextNode, label: UILabel, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) {
        
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
                
        let fontScale: CGFloat
        
        if let textScaleString = textNode.textScale,
            !textScaleString.isEmpty,
            let number = ToolPageViewFactory.numberFormatter.number(from: textScaleString) {
            
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
        label.font = fontService.getFont(size: fontSize * fontScale, weight: fontWeight)
        label.text = textNode.text
        label.textColor = textColor
        label.textAlignment = .left
        
        label.setLineSpacing(lineSpacing: 2)
    }
}
