//
//  ToolPageContentStackViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackViewModel: MobileContentViewModelType {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let node: MobileContentXmlNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let defaultTextNodeTextAlignment: NSTextAlignment
    private let defaultButtonBorderColor: UIColor?
    
    private var buttonEvents: [UIButton: ContentButtonNode] = Dictionary()
    private var linkEvents: [UIButton: ContentLinkNode] = Dictionary()
    private weak var rootContentStack: ToolPageContentStackViewModel?
    
    private(set) var hiddenInputNodes: [ContentInputNode] = Array()
    private(set) var inputViewModels: [ToolPageContentInputViewModelType] = Array()
    
    let containsTips: ObservableValue<Bool> = ObservableValue(value: false)
    let didRenderContentFormSignal: SignalValue<ToolPageContentFormView> = SignalValue()
    let didRenderContentInputSignal: SignalValue<ToolPageContentInputView> = SignalValue()
                
    required init(node: MobileContentXmlNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?, rootContentStack: ToolPageContentStackViewModel?) {
        
        self.node = node
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.defaultTextNodeTextAlignment = defaultTextNodeTextAlignment ?? (diContainer.language.languageDirection == .leftToRight ? .left : .right)
        self.defaultButtonBorderColor = defaultButtonBorderColor
        self.rootContentStack = rootContentStack
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func render(didRenderView: ((_ mobileContentView: MobileContentView) -> Void)) {
        
        // TODO: Need to move rendering into a Class that will return a single Object of results of all rendered contents because
        // If render is called again here we may end up with extra added objects in buttonEvents, etc.
        // Or need to reset objects in this class. ~Levi
        
        for childNode in node.children {
            if let renderedMobileContentView = recurseAndRender(node: childNode, rootContentStack: rootContentStack ?? self) {
                didRenderView(renderedMobileContentView)
            }
        }
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, rootContentStack: ToolPageContentStackViewModel) -> MobileContentView? {
        
        if let paragraphNode = node as? ContentParagraphNode {
        
            let viewModel = ToolPageContentStackViewModel(
                node: paragraphNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor,
                defaultTextNodeTextAlignment: defaultTextNodeTextAlignment,
                defaultButtonBorderColor: defaultButtonBorderColor,
                rootContentStack: rootContentStack
            )
            
            let view = MobileContentStackView(viewModel: viewModel, itemSpacing: 5, scrollIsEnabled: false)
                                                
            return MobileContentView(view: view, heightConstraintType: .constrainedToChildren)
        }
        else if let textNode = node as? ContentTextNode {
                        
            let textLabel: UILabel = getContentText(
                textNode: textNode,
                fontSize: 18,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            )
                        
            return MobileContentView(view: textLabel, heightConstraintType: .intrinsic)
        }
        else if let imageNode = node as? ContentImageNode {
            
            let imageView: UIImageView? = getContentImage(imageNode: imageNode)
            
            guard let view = imageView, let imageSize = imageView?.image?.size else {
                return nil
            }
            
            return MobileContentView(view: view, heightConstraintType: .setToAspectRatioOfProvidedSize(size: imageSize))
        }
        else if let trainingTipNode = node as? TrainingTipNode, let trainingTipId = trainingTipNode.id, diContainer.trainingTipsEnabled {
            
            rootContentStack.containsTips.accept(value: true)
            
            let viewModel = TrainingTipViewModel(
                trainingTipId: trainingTipId,
                manifest: diContainer.manifest,
                translationsFileCache: diContainer.translationsFileCache,
                mobileContentNodeParser: diContainer.mobileContentNodeParser,
                mobileContentEvents: diContainer.mobileContentEvents,
                viewType: .rounded
            )
            
            let view = TrainingTipView(viewModel: viewModel)
            
            let tipSize: CGFloat = 50
            
            return MobileContentView(view: view, heightConstraintType: .equalToSize(size: CGSize(width: tipSize, height: tipSize)))
        }
        else if let buttonNode = node as? ContentButtonNode {
            
            let button: UIButton = getContentButton(
                buttonNode: buttonNode,
                fontSize: 18,
                fontWeight: .regular,
                buttonColor: buttonNode.getColor()?.color ?? toolPageColors.primaryColor,
                borderColor: defaultButtonBorderColor,
                titleColor: buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
            
            addButtonEvent(button: button, buttonNode: buttonNode)
                        
            return MobileContentView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let linkNode = node as? ContentLinkNode {
            
            let button: UIButton = getContentLink(
                linkNode: linkNode,
                fontSize: 18,
                fontWeight: .regular,
                titleColor: linkNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
            
            addLinkEvent(button: button, linkNode: linkNode)
                        
            return MobileContentView(view: button, heightConstraintType: .equalToHeight(height: button.frame.size.height))
        }
        else if let titleNode = node as? TitleNode, let titleTextNode = titleNode.textNode {
                        
            let textLabel: UILabel = getContentText(
                textNode: titleTextNode,
                fontSize: 44,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: titleTextNode.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
                                    
            return MobileContentView(view: textLabel, heightConstraintType: .intrinsic)
        }
        else if let headingNode = node as? HeadingNode, let headingTextNode = headingNode.textNode {
                        
            let textLabel: UILabel = getContentText(
                textNode: headingTextNode,
                fontSize: 30,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: headingNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
                        
            return MobileContentView(view: textLabel, heightConstraintType: .intrinsic)
        }
        else if let tabsNode = node as? ContentTabsNode {
            
            let tabs: ToolPageContentTabsView = getContentTabs(tabsNode: tabsNode)
            
            return MobileContentView(view: tabs, heightConstraintType: .constrainedToChildren)
        }
        else if let inputNode = node as? ContentInputNode {
            
            guard inputNode.type != "hidden" else {
                hiddenInputNodes.append(inputNode)
                return nil
            }
            
            let input: ToolPageContentInputView = getContentInput(inputNode: inputNode)
            
            didRenderContentInputSignal.accept(value: input)
            
            return MobileContentView(view: input, heightConstraintType: .constrainedToChildren)
        }
        else if let formNode = node as? ContentFormNode {
            
            let form: ToolPageContentFormView = getContentForm(formNode: formNode)
            
            didRenderContentFormSignal.accept(value: form)
            
            return MobileContentView(view: form, heightConstraintType: .constrainedToChildren)
        }
        
        return nil
    }
    
    // MARK: - Content Views
        
    private func getContentButton(buttonNode: ContentButtonNode, fontSize: CGFloat, fontWeight: UIFont.Weight, buttonColor: UIColor, borderColor: UIColor?, titleColor: UIColor) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        
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
        
        return button
    }
    
    private func getContentLink(linkNode: ContentLinkNode, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = diContainer.fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(linkNode.textNode?.text, for: .normal)
        
        return button
    }
        
    private func getContentImage(imageNode: ContentImageNode) -> UIImageView? {
        
        guard imageNode.restrictToType == .mobile || imageNode.restrictToType == .noRestriction else {
            return nil
        }
        
        guard let resource = imageNode.resource else {
            return nil
        }
        
        guard let resourceImage = diContainer.manifestResourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        let imageView: UIImageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.image = resourceImage
        
        return imageView
    }
        
    private func getContentText(textNode: ContentTextNode, fontSize: CGFloat, defaultFontWeight: UIFont.Weight, defaultTextAlignment: NSTextAlignment, textColor: UIColor) -> UILabel {
        
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
        
        return label
    }
    
    private func getContentTabs(tabsNode: ContentTabsNode) -> ToolPageContentTabsView {
        
        let viewModel = ToolPageContentTabsViewModel(
            tabsNode: tabsNode,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor
        )
        
        let view = ToolPageContentTabsView(viewModel: viewModel)
        
        return view
    }
    
    private func getContentInput(inputNode: ContentInputNode) -> ToolPageContentInputView {
        
        let viewModel = ToolPageContentInputViewModel(
            inputNode: inputNode,
            fontService: diContainer.fontService,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor
        )
        
        inputViewModels.append(viewModel)
        
        let view = ToolPageContentInputView(viewModel: viewModel)
        
        return view
    }
    
    private func getContentForm(formNode: ContentFormNode) -> ToolPageContentFormView {
        
        let viewModel = ToolPageContentFormViewModel(
            formNode: formNode,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor
        )
        
        let view = ToolPageContentFormView(viewModel: viewModel)
        
        return view
    }
    
    // MARK: - Events
    
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
