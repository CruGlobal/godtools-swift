//
//  ToolPageRendererViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolPageRendererViewFactoryDelegate: class {
    
    func toolPageRendererViewFactoryDidRenderTrainingTip(toolPageRenderer: ToolPageRendererViewFactory)
}

class ToolPageRendererViewFactory: MobileContentRendererViewFactoryType {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let defaultTextNodeTextColor: UIColor?
    private let defaultTextNodeTextAlignment: NSTextAlignment
    private let defaultButtonBorderColor: UIColor?
    
    private weak var delegate: ToolPageRendererViewFactoryDelegate?
        
    required init(diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?, delegate: ToolPageRendererViewFactoryDelegate?) {
        
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.defaultTextNodeTextAlignment = defaultTextNodeTextAlignment ?? (diContainer.language.languageDirection == .leftToRight ? .left : .right)
        self.defaultButtonBorderColor = defaultButtonBorderColor
        self.delegate = delegate
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode) -> MobileContentRenderableView? {
                
        if renderableNode is ContentParagraphNode {
            
            return MobileContentStackView(itemSpacing: 5, scrollIsEnabled: false)
        }
        else if renderableNode is CardNode {
            
            return MobileContentStackView(itemSpacing: 20, scrollIsEnabled: true)
        }
        else if renderableNode is HeroNode {
            
            return MobileContentStackView(itemSpacing: 20, scrollIsEnabled: true)
        }
        else if let textNode = renderableNode as? ContentTextNode {
            
            let label: UILabel = UILabel()
            
            renderContentText(
                label: label,
                textNode: textNode
            )
                        
            return MobileContentStackRenderedView(view: label, heightConstraintType: .intrinsic)
        }
        else if let imageNode = renderableNode as? ContentImageNode {
            
            let imageView: UIImageView = UIImageView()
            
            if renderContentImage(imageView: imageView, imageNode: imageNode, languageDirectionSemanticContentAttribute: diContainer.languageDirectionSemanticContentAttribute), let imageSize = imageView.image?.size {
                                  
                return MobileContentStackRenderedView(view: imageView, heightConstraintType: .setToAspectRatioOfProvidedSize(size: imageSize))
            }
        }
        else if let trainingTipNode = renderableNode as? TrainingTipNode {
            
            if let view = renderTrainingTip(trainingTipNode: trainingTipNode) {
                  
                delegate?.toolPageRendererViewFactoryDidRenderTrainingTip(toolPageRenderer: self)
                
                let tipSize: CGFloat = 50
                
                return MobileContentStackRenderedView(view: view, heightConstraintType: .equalToSize(size: CGSize(width: tipSize, height: tipSize)))
            }
        }
        else if let buttonNode = renderableNode as? ContentButtonNode {
            
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
                        
            return MobileContentStackRenderedView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let linkNode = renderableNode as? ContentLinkNode {
            
            let button: UIButton = UIButton(type: .custom)
            
            renderContentLink(
                button: button,
                linkNode: linkNode,
                fontSize: 18,
                fontWeight: .regular,
                titleColor: linkNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
                                                
            return MobileContentStackRenderedView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let titleNode = renderableNode as? TitleNode {
                          
            let label: UILabel = UILabel()
            
            renderTitle(
                label: label,
                titleNode: titleNode
            )
                                    
            return MobileContentStackRenderedView(view: label, heightConstraintType: .intrinsic)
        }
        else if let headingNode = renderableNode as? HeadingNode {
              
            let label: UILabel = UILabel()
            
            renderHeading(
                label: label,
                headingNode: headingNode
            )
                      
            return MobileContentStackRenderedView(view: label, heightConstraintType: .intrinsic)
        }
        else if let tabsNode = renderableNode as? ContentTabsNode {

            let viewModel = ToolPageContentTabsViewModel(
                tabsNode: tabsNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentTabsView(viewModel: viewModel)
                                    
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if renderableNode is ContentTabNode {
            
            return MobileContentStackView(itemSpacing: 10, scrollIsEnabled: false)
        }
        else if let inputNode = renderableNode as? ContentInputNode {
                    
            guard inputNode.type != "hidden" else {
                // TODO: Need to add this back in. ~Levi
                //rootContentStackRenderer.didRenderHiddenContentInputSignal.accept(value: inputNode)
                return nil
            }
            
            let viewModel = ToolPageContentInputViewModel(
                inputNode: inputNode,
                fontService: diContainer.fontService,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentInputView(viewModel: viewModel)
            
            let renderedInput = ToolPageRenderedContentInput(viewModel: viewModel, view: view)
            
            // TODO: Need to add this back in. ~Levi
            //rootContentStackRenderer.didRenderContentInputSignal.accept(value: renderedInput)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let formNode = renderableNode as? ContentFormNode {
            
            let viewModel = ToolPageContentFormViewModel(
                formNode: formNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentFormView(viewModel: viewModel)
              
            // TODO: Need to add this back in. ~Levi
            //rootContentStackRenderer.didRenderContentFormSignal.accept(value: view)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if renderableNode is ModalNode {
            
            return MobileContentStackView(itemSpacing: 15, scrollIsEnabled: true)
        }
        else if renderableNode is TipNode {
            
            return MobileContentStackView(itemSpacing: 15, scrollIsEnabled: true)
        }
        
        return nil
    }
    
    // MARK: - Rendering
    
    private func renderContentButton(button: UIButton, buttonNode: ContentButtonNode, fontSize: CGFloat, fontWeight: UIFont.Weight, buttonColor: UIColor, borderColor: UIColor?, titleColor: UIColor) {
        
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
    
    private func renderContentLink(button: UIButton, linkNode: ContentLinkNode, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) {
        
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = diContainer.fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(linkNode.textNode?.text, for: .normal)
    }
    
    private func renderContentImage(imageView: UIImageView, imageNode: ContentImageNode, languageDirectionSemanticContentAttribute: UISemanticContentAttribute) -> Bool {
        
        imageView.backgroundColor = .clear
        
        guard imageNode.isRenderable else {
            return false
        }
        
        guard let resource = imageNode.resource else {
            return false
        }
        
        guard let resourceImage = diContainer.manifestResourcesCache.getImage(resource: resource) else {
            return false
        }
        
        if languageDirectionSemanticContentAttribute == .forceRightToLeft {
            imageView.semanticContentAttribute = .forceRightToLeft
            imageView.image = resourceImage.imageFlippedForRightToLeftLayoutDirection()
        }
        else {
            imageView.semanticContentAttribute = .forceLeftToRight
            imageView.image = resourceImage
        }
        
        return true
    }
    
    private func renderContentText(label: UILabel, textNode: ContentTextNode) {
        
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
            let number = ToolPageRendererViewFactory.numberFormatter.number(from: textScaleString) {
            
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
    
    private func renderTitle(label: UILabel, titleNode: TitleNode) {
        
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
    
    private func renderHeading(label: UILabel, headingNode: HeadingNode) {
        
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
    
    private func renderTrainingTip(trainingTipNode: TrainingTipNode) -> TrainingTipView? {
        
        guard let trainingTipId = trainingTipNode.id, !trainingTipId.isEmpty, diContainer.trainingTipsEnabled else {
            return nil
        }
        
        let viewModel = TrainingTipViewModel(
            trainingTipId: trainingTipId,
            resource: diContainer.resource,
            language: diContainer.language,
            manifest: diContainer.manifest,
            translationsFileCache: diContainer.translationsFileCache,
            mobileContentNodeParser: diContainer.mobileContentNodeParser,
            mobileContentEvents: diContainer.mobileContentEvents,
            viewType: .rounded,
            viewedTrainingTips: diContainer.viewedTrainingTips
        )
        
        let view = TrainingTipView(viewModel: viewModel)
        
        return view
    }
}
