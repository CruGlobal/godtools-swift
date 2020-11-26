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
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let defaultTextNodeTextAlignment: NSTextAlignment
    private let defaultButtonBorderColor: UIColor?
    
    private var buttonEvents: [UIButton: ContentButtonNode] = Dictionary()
    private var linkEvents: [UIButton: ContentLinkNode] = Dictionary()
    
    private weak var rootContentStackRenderer: ToolPageContentStackRenderer?
        
    let didRenderContentFormSignal: SignalValue<ToolPageContentFormView> = SignalValue()
    let didRenderHiddenContentInputSignal: SignalValue<ContentInputNode> = SignalValue()
    let didRenderContentInputSignal: SignalValue<ToolPageRenderedContentInput> = SignalValue()
    let didRenderTrainingTipsSignal: Signal = Signal()
    
    required init(rootContentStackRenderer: ToolPageContentStackRenderer?, diContainer: ToolPageDiContainer, node: MobileContentXmlNode, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?) {
        
        self.rootContentStackRenderer = rootContentStackRenderer
        self.diContainer = diContainer
        self.node = node
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.defaultTextNodeTextAlignment = defaultTextNodeTextAlignment ?? (diContainer.language.languageDirection == .leftToRight ? .left : .right)
        self.defaultButtonBorderColor = defaultButtonBorderColor
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func resetForNewRender() {
        removeAllButtonEvents()
        removeAllLinkEvents()
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
                      
            let label: UILabel = UILabel()
            
            renderContentText(
                label: label,
                textNode: textNode
            )
                        
            return MobileContentStackRenderedView(view: label, heightConstraintType: .intrinsic)
        }
        else if let imageNode = node as? ContentImageNode {
            
            let imageView: UIImageView = UIImageView()
            
            if renderContentImage(imageView: imageView, imageNode: imageNode), let imageSize = imageView.image?.size {
                
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
                          
            rootContentStackRenderer.addButtonEvent(button: button, buttonNode: buttonNode)
            
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
            
            rootContentStackRenderer.addLinkEvent(button: button, linkNode: linkNode)
                                    
            return MobileContentStackRenderedView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let titleNode = node as? TitleNode {
                  
            let label: UILabel = UILabel()
            
            renderTitle(
                label: label,
                titleNode: titleNode
            )
                                    
            return MobileContentStackRenderedView(view: label, heightConstraintType: .intrinsic)
        }
        else if let headingNode = node as? HeadingNode {
              
            let label: UILabel = UILabel()
            
            renderHeading(
                label: label,
                headingNode: headingNode
            )
                      
            return MobileContentStackRenderedView(view: label, heightConstraintType: .intrinsic)
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
            
            let renderedInput = ToolPageRenderedContentInput(visibleInputViewModel: viewModel, visibleInputView: view)
            
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
            let number = ToolPageContentStackRenderer.numberFormatter.number(from: textScaleString) {
            
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
    
    // MARK: - Button Events
    
    private func removeAllButtonEvents() {
        
        let buttons: [UIButton] = Array(buttonEvents.keys)
        
        for button in buttons {
            button.removeTarget(self, action: #selector(handleButtonTapped(button:)), for: .touchUpInside)
        }
        
        buttonEvents.removeAll()
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
        
        if buttonNode.type == "event" {
            
            let followUpSendEventName: String = "followup:send"
            
            if buttonNode.events.contains(followUpSendEventName) {
                var triggerEvents: [String] = buttonNode.events
                if let index = triggerEvents.firstIndex(of: followUpSendEventName) {
                    triggerEvents.remove(at: index)
                }
                diContainer.mobileContentEvents.followUpEventButtonTapped(followUpEventButton: FollowUpButtonEvent(triggerEventsOnFollowUpSent: triggerEvents))
            }
            else {
                for event in buttonNode.events {
                    diContainer.mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
                }
            }
        }
        else if buttonNode.type == "url", let url = buttonNode.url {
            diContainer.mobileContentEvents.urlButtonTapped(urlButtonEvent: UrlButtonEvent(url: url))
        }
        
        if let analyticsEventsNode = buttonNode.analyticsEventsNode {
            diContainer.mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
    
    // MARK: - Link Events
    
    private func removeAllLinkEvents() {
        
        let linkButtons: [UIButton] = Array(linkEvents.keys)
        
        for linkButton in linkButtons {
            linkButton.removeTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
        }
        
        linkEvents.removeAll()
    }
    
    private func addLinkEvent(button: UIButton, linkNode: ContentLinkNode) {
        
        guard linkEvents[button] == nil else {
            return
        }
        
        linkEvents[button] = linkNode
        
        button.addTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
    }
    
    private func removeLinkEvent(button: UIButton) {
        
        guard linkEvents[button] != nil else {
            return
        }
        
        linkEvents[button] = nil
        
        button.removeTarget(self, action: #selector(handleLinkTapped(button:)), for: .touchUpInside)
    }
    
    @objc func handleLinkTapped(button: UIButton) {
        
        guard let linkNode = linkEvents[button] else {
            return
        }
        
        for event in linkNode.events {
            diContainer.mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
        }
        
        if let analyticsEventsNode = linkNode.analyticsEventsNode {
            diContainer.mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
