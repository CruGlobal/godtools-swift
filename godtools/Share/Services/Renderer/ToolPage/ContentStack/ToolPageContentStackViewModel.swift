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
    private let toolPageViewFactory: ToolPageViewFactory
    private let fontService: FontService
    private let defaultTextNodeTextColor: UIColor?
    
    let itemSpacing: CGFloat
    let scrollIsEnabled: Bool
    let toolPageColors: ToolPageColorsViewModel
    
    required init(node: MobileContentXmlNode, itemSpacing: CGFloat, scrollIsEnabled: Bool, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, toolPageViewFactory: ToolPageViewFactory, fontService: FontService) {
        
        self.node = node
        self.itemSpacing = itemSpacing
        self.scrollIsEnabled = scrollIsEnabled
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.toolPageViewFactory = toolPageViewFactory
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
                toolPageViewFactory: toolPageViewFactory,
                fontService: fontService
            )
            
            let view = ToolPageContentStackView(viewModel: viewModel)
            
            return view
        }
        else if let textNode = node as? ContentTextNode {
            
            return toolPageViewFactory.getContentTextNodeLabel(
                textNode: textNode,
                fontSize: 18,
                fontWeight: .regular,
                textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            )
        }
        else if let imageNode = node as? ContentImageNode {
            
            return toolPageViewFactory.getContentImageNodeImage(
                imageNode: imageNode,
                manifest: manifest,
                translationsFileCache: translationsFileCache
            )
        }
        else if let buttonNode = node as? ContentButtonNode {
            
            let button: UIButton = toolPageViewFactory.getContentButtonNodeButton(
                buttonNode: buttonNode,
                fontSize: 18,
                fontWeight: .regular,
                buttonColor: toolPageColors.primaryColor,
                titleColor: buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
            
            return button
        }
        else if let headingNode = node as? HeadingNode, let headingTextNode = headingNode.textNode {
            
            return toolPageViewFactory.getContentTextNodeLabel(
                textNode: headingTextNode,
                fontSize: 30,
                fontWeight: .regular,
                textColor: headingNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
        }
        
        return nil
    }
}
