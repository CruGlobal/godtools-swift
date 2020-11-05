//
//  ToolPageContentStackViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackViewModel {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let node: MobileContentXmlNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let fontService: FontService
    private let defaultTextNodeTextColor: UIColor?
    
    let itemSpacing: CGFloat
    let scrollIsEnabled: Bool
    let toolPageColors: ToolPageColorsViewModel
    
    required init(node: MobileContentXmlNode, itemSpacing: CGFloat, scrollIsEnabled: Bool, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, fontService: FontService) {
        
        self.node = node
        self.itemSpacing = itemSpacing
        self.scrollIsEnabled = scrollIsEnabled
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.fontService = fontService
    }
    
    func render(didRenderView: ((_ view: UIView) -> Void)) {
        
        for childNode in node.children {
            if let renderedView = recurseAndRender(node: childNode) {
                didRenderView(renderedView)
            }
        }
    }
    
    private func recurseAndRender(node: MobileContentXmlNode) -> UIView? {
        
        if let paragraphNode = node as? ContentParagraphNode {
            
            let viewModel = ToolPageContentStackViewModel(
                node: paragraphNode,
                itemSpacing: 5,
                scrollIsEnabled: false,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                fontService: fontService
            )
            
            let view = ToolPageContentStackView(viewModel: viewModel)
            
            return view
        }
        else if let textNode = node as? ContentTextNode {
            
            let textLabel: UILabel = getLabel(
                textNode: textNode,
                fontSize: 18,
                fontWeight: .regular,
                textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            )
            
            return textLabel
        }
        else if let imageNode = node as? ContentImageNode {
            
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
            
            let imageView: UIImageView = getImageView(image: resourceImage)
            
            return imageView
        }
        else if let headingNode = node as? HeadingNode {
            
            let headingLabel: UILabel = getLabel(
                textNode: headingNode.textNode,
                fontSize: 30,
                fontWeight: .regular,
                textColor: headingNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
            
            headingLabel.textColor = headingNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            
            return headingLabel
        }
        
        return nil
    }
    
    private func getButton(title: String?) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        
        return button
    }
    
    private func getLabel(textNode: ContentTextNode?, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
        
        let label: UILabel = UILabel()
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
                
        let fontScale: CGFloat
        
        if let textScaleString = textNode?.textScale,
            !textScaleString.isEmpty,
            let number = ToolPageContentStackViewModel.numberFormatter.number(from: textScaleString) {
            
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
        label.font = fontService.getFont(size: fontSize * fontScale, weight: fontWeight)
        label.text = textNode?.text
        label.textColor = textColor
        label.textAlignment = .left
        
        label.setLineSpacing(lineSpacing: 2)
        
        return label
    }
    
    private func getImageView(image: UIImage) -> UIImageView {
        
        let imageView: UIImageView = UIImageView()
        imageView.image = image
        
        return imageView
    }
}
