//
//  ToolPageContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentRenderer {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let defaultTextNodeTextAlignment: NSTextAlignment
    private let defaultButtonBorderColor: UIColor?
        
    let didRenderContentFormSignal: SignalValue<ToolPageContentFormView> = SignalValue()
    let didRenderContentInputSignal: SignalValue<ToolPageContentInputView> = SignalValue()
    
    required init(diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?) {
        
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.defaultTextNodeTextAlignment = defaultTextNodeTextAlignment ?? (diContainer.language.languageDirection == .leftToRight ? .left : .right)
        self.defaultButtonBorderColor = defaultButtonBorderColor
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func renderContent(node: MobileContentXmlNode, rootContentRenderer: ToolPageContentRenderer?, didRenderView: ((_ mobileContentView: MobileContentView) -> Void)) -> ToolPageRenderedContent {
                
        let renderedContent: ToolPageRenderedContent = ToolPageRenderedContent(
            mobileContentAnalytics: diContainer.mobileContentAnalytics,
            mobileContentEvents: diContainer.mobileContentEvents
        )
        
        for childNode in node.children {
            
            let renderedView: MobileContentView? = recurseAndRender(
                node: childNode,
                rootContentRenderer: rootContentRenderer ?? self,
                renderedContent: renderedContent
            )
            
            if let renderedView = renderedView {
                
                didRenderView(renderedView)
            }
        }
        
        return renderedContent
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, rootContentRenderer: ToolPageContentRenderer, renderedContent: ToolPageRenderedContent) -> MobileContentView? {
        
        if let paragraphNode = node as? ContentParagraphNode {
        
            let viewModel = ContentParagraphViewModel(
                node: paragraphNode,
                rootContentRenderer: rootContentRenderer
            )
            
            let view = MobileContentStackView(
                viewModel: viewModel,
                itemSpacing: 5,
                scrollIsEnabled: false
            )
                                                         
            return MobileContentView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let textNode = node as? ContentTextNode {
                      
            let label: UILabel = UILabel()
            
            renderContentText(
                label: label,
                textNode: textNode
            )
                        
            return MobileContentView(view: label, heightConstraintType: .intrinsic)
        }
        else if let imageNode = node as? ContentImageNode {
            
            let imageView: UIImageView = UIImageView()
            
            if renderContentImage(imageView: imageView, imageNode: imageNode), let imageSize = imageView.image?.size {
                
                return MobileContentView(view: imageView, heightConstraintType: .setToAspectRatioOfProvidedSize(size: imageSize))
            }
        }
        else if let trainingTipNode = node as? TrainingTipNode {
            
            if let view = renderTrainingTip(trainingTipNode: trainingTipNode) {
                                          
                renderedContent.containsTips.accept(value: true)
                
                let tipSize: CGFloat = 50
                
                return MobileContentView(view: view, heightConstraintType: .equalToSize(size: CGSize(width: tipSize, height: tipSize)))
            }
        }
        else if let buttonNode = node as? ContentButtonNode {
            
            let button: UIButton = UIButton(type: .custom)
            
            renderContentButton(
                button: button,
                buttonNode: buttonNode,
                fontSize: 18,
                fontWeight: .regular,
                buttonColor: buttonNode.getColor()?.color ?? toolPageColors.primaryColor,
                borderColor: defaultButtonBorderColor,
                titleColor: buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
                          
            renderedContent.addButtonEvent(button: button, buttonNode: buttonNode)
            
            return MobileContentView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let linkNode = node as? ContentLinkNode {
            
            let button: UIButton = UIButton(type: .custom)
            
            renderContentLink(
                button: button,
                linkNode: linkNode,
                fontSize: 18,
                fontWeight: .regular,
                titleColor: linkNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
            
            renderedContent.addLinkEvent(button: button, linkNode: linkNode)
                                    
            return MobileContentView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let titleNode = node as? TitleNode {
                  
            let label: UILabel = UILabel()
            
            renderTitle(
                label: label,
                titleNode: titleNode
            )
                                    
            return MobileContentView(view: label, heightConstraintType: .intrinsic)
        }
        else if let headingNode = node as? HeadingNode {
              
            let label: UILabel = UILabel()
            
            renderHeading(
                label: label,
                headingNode: headingNode
            )
                      
            return MobileContentView(view: label, heightConstraintType: .intrinsic)
        }
        else if let tabsNode = node as? ContentTabsNode {

            let viewModel = ToolPageContentTabsViewModel(
                tabsNode: tabsNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentTabsView(viewModel: viewModel)
                                    
            return MobileContentView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let inputNode = node as? ContentInputNode {
            
            guard inputNode.type != "hidden" else {
                // TODO: Implement. ~Levi
                //hiddenInputNodes.append(inputNode)
                return nil
            }
            
            let viewModel = ToolPageContentInputViewModel(
                inputNode: inputNode,
                fontService: diContainer.fontService,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            // TODO: Implement. ~Levi
            //inputViewModels.append(viewModel)
            
            let view = ToolPageContentInputView(viewModel: viewModel)
            
            return MobileContentView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let formNode = node as? ContentFormNode {
            
            let viewModel = ToolPageContentFormViewModel(
                formNode: formNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentFormView(viewModel: viewModel)
                        
            didRenderContentFormSignal.accept(value: view)
            
            return MobileContentView(view: view, heightConstraintType: .constrainedToChildren)
        }
        
        return nil
    }
    
    // MARK: - Rendering
    
    func renderContentButton(button: UIButton, buttonNode: ContentButtonNode, fontSize: CGFloat, fontWeight: UIFont.Weight, buttonColor: UIColor, borderColor: UIColor?, titleColor: UIColor) {
        
        button.backgroundColor = buttonColor
        if let borderColor = borderColor {
            button.layer.borderColor = borderColor.cgColor
            button.layer.borderWidth = 1
        }
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = diContainer.fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(buttonNode.textNode?.text, for: .normal)
    }
    
    func renderContentLink(button: UIButton, linkNode: ContentLinkNode, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) {
        
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = diContainer.fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(linkNode.textNode?.text, for: .normal)
    }
    
    func renderContentImage(imageView: UIImageView, imageNode: ContentImageNode) -> Bool {
        
        imageView.backgroundColor = .clear
        
        guard imageNode.restrictToType == .mobile || imageNode.restrictToType == .noRestriction else {
            return false
        }
        
        guard let resource = imageNode.resource else {
            return false
        }
        
        guard let resourceImage = diContainer.manifestResourcesCache.getImage(resource: resource) else {
            return false
        }
        
        imageView.image = resourceImage
        
        return true
    }
    
    func renderContentText(label: UILabel, textNode: ContentTextNode) {
        
        renderText(
            label: label,
            textNode: textNode,
            fontSize: 18,
            defaultFontWeight: .regular,
            defaultTextAlignment: defaultTextNodeTextAlignment,
            textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
        )
    }
    
    private func renderText(label: UILabel, textNode: ContentTextNode, fontSize: CGFloat, defaultFontWeight: UIFont.Weight, defaultTextAlignment: NSTextAlignment, textColor: UIColor) {
        
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
                
        let fontScale: CGFloat
        
        if let textScaleString = textNode.textScale,
            !textScaleString.isEmpty,
            let number = ToolPageContentRenderer.numberFormatter.number(from: textScaleString) {
            
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
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
        
        label.font = diContainer.fontService.getFont(size: fontSize * fontScale, weight: fontWeight)
        label.text = textNode.text
        label.textColor = textColor
        label.textAlignment = textAlignment
        
        label.setLineSpacing(lineSpacing: 2)
    }
    
    func renderTitle(label: UILabel, titleNode: TitleNode) {
        
        guard let textNode = titleNode.textNode else {
            return
        }
        
        renderText(
            label: label,
            textNode: textNode,
            fontSize: 44,
            defaultFontWeight: .regular,
            defaultTextAlignment: defaultTextNodeTextAlignment,
            textColor: textNode.getTextColor()?.color ?? toolPageColors.primaryTextColor
        )
    }
    
    func renderHeading(label: UILabel, headingNode: HeadingNode) {
        
        guard let textNode = headingNode.textNode else {
            return
        }
        
        renderText(
            label: label,
            textNode: textNode,
            fontSize: 30,
            defaultFontWeight: .regular,
            defaultTextAlignment: defaultTextNodeTextAlignment,
            textColor: textNode.getTextColor()?.color ?? toolPageColors.primaryColor
        )
    }
    
    func renderTrainingTip(trainingTipNode: TrainingTipNode) -> TrainingTipView? {
        
        guard let trainingTipId = trainingTipNode.id, !trainingTipId.isEmpty, diContainer.trainingTipsEnabled else {
            return nil
        }
        
        let viewModel = TrainingTipViewModel(
            trainingTipId: trainingTipId,
            manifest: diContainer.manifest,
            translationsFileCache: diContainer.translationsFileCache,
            mobileContentNodeParser: diContainer.mobileContentNodeParser,
            mobileContentEvents: diContainer.mobileContentEvents,
            viewType: .rounded
        )
        
        let view = TrainingTipView(viewModel: viewModel)
        
        return view
    }
}
