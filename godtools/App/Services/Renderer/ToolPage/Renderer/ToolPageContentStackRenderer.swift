//
//  ToolPageContentStackRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 11/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackRenderer: MobileContentStackViewRendererType {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let diContainer: ToolPageDiContainer
    private let node: MobileContentXmlNode
    private let toolPageColors: ToolPageColors
    private let defaultTextNodeTextColor: UIColor?
    private let defaultTextNodeTextAlignment: NSTextAlignment
    private let defaultButtonBorderColor: UIColor?
    private let buttonEvents: ToolPageContentButtonEvents
    private let linkEvents: ToolPageContentLinkEvents
    private let imageEvents: ToolPageContentImageEvents
    
    private weak var rootContentStackRenderer: ToolPageContentStackRenderer?
        
    let didRenderContentFormSignal: SignalValue<ToolPageContentFormView> = SignalValue()
    let didRenderHiddenContentInputSignal: SignalValue<ContentInputNode> = SignalValue()
    let didRenderContentInputSignal: SignalValue<ToolPageRenderedContentInput> = SignalValue()
    let didRenderTrainingTipsSignal: Signal = Signal()
        
    required init(rootContentStackRenderer: ToolPageContentStackRenderer?, diContainer: ToolPageDiContainer, node: MobileContentXmlNode, toolPageColors: ToolPageColors, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?) {
        
        self.rootContentStackRenderer = rootContentStackRenderer
        self.diContainer = diContainer
        self.node = node
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.defaultTextNodeTextAlignment = defaultTextNodeTextAlignment ?? (diContainer.language.languageDirection == .leftToRight ? .left : .right)
        self.defaultButtonBorderColor = defaultButtonBorderColor
        self.buttonEvents = ToolPageContentButtonEvents(mobileContentEvents: diContainer.mobileContentEvents, mobileContentAnalytics: diContainer.mobileContentAnalytics)
        self.linkEvents = ToolPageContentLinkEvents(mobileContentEvents: diContainer.mobileContentEvents, mobileContentAnalytics: diContainer.mobileContentAnalytics)
        self.imageEvents = ToolPageContentImageEvents(mobileContentEvents: diContainer.mobileContentEvents)
    }
    
    deinit {

    }
    
    private func resetForNewRender() {
        buttonEvents.removeAllButtonEvents()
        linkEvents.removeAllLinkEvents()
        imageEvents.removeAllImageEvents()
    }
    
    func render(didRenderView: ((_ renderedView: MobileContentStackRenderedView) -> Void)) {
                
        resetForNewRender()
        
        for childNode in node.children {
            
            let renderedView: MobileContentStackRenderedView? = recurseAndRender(
                node: childNode,
                rootContentStackRenderer: rootContentStackRenderer ?? self
            )
            
            if let renderedView = renderedView {
                
                didRenderView(renderedView)
            }
        }
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, rootContentStackRenderer: ToolPageContentStackRenderer) -> MobileContentStackRenderedView? {
        
        if let paragraphNode = node as? ContentParagraphNode {
        
            let paragraphRenderer = ToolPageContentStackRenderer(
                rootContentStackRenderer: rootContentStackRenderer,
                diContainer: diContainer,
                node: paragraphNode,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor,
                defaultTextNodeTextAlignment: defaultTextNodeTextAlignment,
                defaultButtonBorderColor: defaultButtonBorderColor
            )
            
            let view = MobileContentStackView(
                viewRenderer: paragraphRenderer,
                itemSpacing: 5,
                scrollIsEnabled: false
            )
                                                         
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let textNode = node as? ContentTextNode {
              
            let viewModel = MobileContentTextViewModel(
                contentTextNode: textNode,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                fontService: diContainer.fontService,
                fontSize: 18,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            )

            let view = MobileContentTextView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let imageNode = node as? ContentImageNode {
            
            let imageView: UIImageView = UIImageView()
            
            if renderContentImage(imageView: imageView, imageNode: imageNode, languageDirectionSemanticContentAttribute: diContainer.languageDirectionSemanticContentAttribute), let imageSize = imageView.image?.size {
                                
                rootContentStackRenderer.imageEvents.addImageEvent(image: imageView, imageNode: imageNode)
                
                return MobileContentStackRenderedView(view: imageView, heightConstraintType: .setToAspectRatioOfProvidedSize(size: imageSize))
            }
        }
        else if let trainingTipNode = node as? TrainingTipNode {
            
            if let view = renderTrainingTip(trainingTipNode: trainingTipNode) {
                                          
                rootContentStackRenderer.didRenderTrainingTipsSignal.accept()
                
                let tipSize: CGFloat = 50
                
                return MobileContentStackRenderedView(view: view, heightConstraintType: .equalToSize(size: CGSize(width: tipSize, height: tipSize)))
            }
        }
        else if let buttonNode = node as? ContentButtonNode {
            
            guard buttonNode.buttonType != .unknown else {
                return nil
            }
            
            let button: UIButton = UIButton(type: .custom)
            
            let defaultBackgroundColor: UIColor = buttonNode.getColor()?.color ?? toolPageColors.primaryColor
            let defaultTitleColor: UIColor = buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
            
            let backgroundColor: UIColor
            let titleColor: UIColor
            let borderColor: UIColor?
            let fontSize: CGFloat = 18
            let fontWeight: UIFont.Weight = .regular
            
            switch buttonNode.buttonStyle {
            
            case .contained:
                backgroundColor = defaultBackgroundColor
                titleColor = defaultTitleColor
                borderColor = defaultButtonBorderColor
            case .outlined:
                backgroundColor = buttonNode.getBackgroundColor()?.color ?? .clear
                titleColor = defaultBackgroundColor
                borderColor = defaultBackgroundColor
            }
            
            button.backgroundColor = backgroundColor
            if let borderColor = borderColor {
                button.layer.borderColor = borderColor.cgColor
                button.layer.borderWidth = 1
            }
            button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
            button.layer.cornerRadius = 5
            button.titleLabel?.font = diContainer.fontService.getFont(size: fontSize, weight: fontWeight)
            button.setTitleColor(titleColor, for: .normal)
            button.setTitle(buttonNode.textNode?.text, for: .normal)
               
            rootContentStackRenderer.buttonEvents.addButtonEvent(button: button, buttonNode: buttonNode)
            
            return MobileContentStackRenderedView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
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
            
            rootContentStackRenderer.linkEvents.addLinkEvent(button: button, linkNode: linkNode)
                                    
            return MobileContentStackRenderedView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let fallbackNode = node as? ContentFallbackNode {
            
            return renderContentFallback(contentFallbackNode: fallbackNode, rootContentStackRenderer: rootContentStackRenderer)
        }
        else if let titleNode = node as? TitleNode, let textNode = titleNode.textNode {
                  
            let viewModel = MobileContentTextViewModel(
                contentTextNode: textNode,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                fontService: diContainer.fontService,
                fontSize: 44,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )

            let view = MobileContentTextView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let headingNode = node as? HeadingNode, let textNode = headingNode.textNode {
            
            let viewModel = MobileContentTextViewModel(
                contentTextNode: textNode,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                fontService: diContainer.fontService,
                fontSize: 30,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? toolPageColors.primaryColor
            )

            let view = MobileContentTextView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let tabsNode = node as? ContentTabsNode {

            let viewModel = ToolPageContentTabsViewModel(
                tabsNode: tabsNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentTabsView(viewModel: viewModel)
                                    
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let inputNode = node as? ContentInputNode {
            
            guard inputNode.type != "hidden" else {
                rootContentStackRenderer.didRenderHiddenContentInputSignal.accept(value: inputNode)
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
            
            rootContentStackRenderer.didRenderContentInputSignal.accept(value: renderedInput)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let formNode = node as? ContentFormNode {
            
            let viewModel = ToolPageContentFormViewModel(
                formNode: formNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = ToolPageContentFormView(viewModel: viewModel)
                        
            rootContentStackRenderer.didRenderContentFormSignal.accept(value: view)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if node is ContentSpacerNode {
            
            return MobileContentStackRenderedView(view: MobileContentSpacerView(), heightConstraintType: .spacer)
        }
        
        return nil
    }
    
    // MARK: - Rendering
    
    private func renderContentFallback(contentFallbackNode: MobileContentXmlNode, rootContentStackRenderer: ToolPageContentStackRenderer) -> MobileContentStackRenderedView? {
        
        var nodeToRender: MobileContentXmlNode?
        
        for childNode in contentFallbackNode.children {
            
            guard let renderableNode = childNode as? MobileContentRenderableNode else {
                continue
            }
            
            guard renderableNode.isRenderable else {
                continue
            }
            
            nodeToRender = childNode
            break
        }
        
        if let nodeToRender = nodeToRender {
            return recurseAndRender(node: nodeToRender, rootContentStackRenderer: rootContentStackRenderer)
        }
        
        return nil
    }
    
    func renderContentLink(button: UIButton, linkNode: ContentLinkNode, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) {
        
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = diContainer.fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(linkNode.textNode?.text, for: .normal)
    }
    
    func renderContentImage(imageView: UIImageView, imageNode: ContentImageNode, languageDirectionSemanticContentAttribute: UISemanticContentAttribute) -> Bool {
        
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
    
    func renderTrainingTip(trainingTipNode: TrainingTipNode) -> TrainingTipView? {
        
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
