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
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let defaultTextNodeTextColor: UIColor?
    
    private var buttonEvents: [UIButton: ContentButtonNode] = Dictionary()
            
    let itemSpacing: CGFloat
    let scrollIsEnabled: Bool
    let toolPageColors: ToolPageColorsViewModel
    
    required init(node: MobileContentXmlNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentEvents: MobileContentEvents, fontService: FontService, itemSpacing: CGFloat, scrollIsEnabled: Bool, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.node = node
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.itemSpacing = itemSpacing
        self.scrollIsEnabled = scrollIsEnabled
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                itemSpacing: 5,
                scrollIsEnabled: false,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentStackView(viewModel: viewModel)
            
            return view
        }
        else if let textNode = node as? ContentTextNode {
            
            return getContentText(
                textNode: textNode,
                fontSize: 18,
                fontWeight: .regular,
                textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            )
        }
        else if let imageNode = node as? ContentImageNode {
            
            return getContentImage(imageNode: imageNode)
        }
        else if let buttonNode = node as? ContentButtonNode {
            
            let button: UIButton = getContentButton(
                buttonNode: buttonNode,
                fontSize: 18,
                fontWeight: .regular,
                buttonColor: toolPageColors.primaryColor,
                titleColor: buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
                        
            return button
        }
        else if let headingNode = node as? HeadingNode, let headingTextNode = headingNode.textNode {
            
            return getContentText(
                textNode: headingTextNode,
                fontSize: 30,
                fontWeight: .regular,
                textColor: headingNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
        }
        
        return nil
    }
        
    private func getContentButton(buttonNode: ContentButtonNode, fontSize: CGFloat, fontWeight: UIFont.Weight, buttonColor: UIColor, titleColor: UIColor) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        
        button.backgroundColor = buttonColor
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(buttonNode.textNode?.text, for: .normal)

        addButtonEvent(button: button, buttonNode: buttonNode)
        
        return button
    }
        
    private func getContentImage(imageNode: ContentImageNode) -> UIImageView? {
        
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
        
    private func getContentText(textNode: ContentTextNode, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
        
        let label: UILabel = UILabel()
        
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
                
        let fontScale: CGFloat
        
        if let textScaleString = textNode.textScale,
            !textScaleString.isEmpty,
            let number = ToolPageContentStackViewModel.numberFormatter.number(from: textScaleString) {
            
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
        
        return label
    }
    
    private func addButtonEvent(button: UIButton, buttonNode: ContentButtonNode) {
        
        guard buttonEvents[button] == nil else {
            return
        }
        
        buttonEvents[button] = buttonNode
        
        button.addTarget(self, action: #selector(handleButtonTapped(button:)), for: .touchUpInside)
    }
    
    private func removeButtonEvent(button: UIButton) {
        
        guard buttonEvents[button] != nil else {
            return
        }
        
        buttonEvents[button] = nil
        
        button.removeTarget(self, action: #selector(handleButtonTapped(button:)), for: .touchUpInside)
    }
    
    @objc func handleButtonTapped(button: UIButton) {
        
        guard let buttonNode = buttonEvents[button] else {
            return
        }
        
        if buttonNode.type == "url", let url = buttonNode.url {
            mobileContentEvents.urlButtonTapped(url: url)
        }
    }
}
