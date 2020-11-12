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
    private let language: LanguageModel
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let followUpsService: FollowUpsService
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    private let defaultButtonBorderColor: UIColor?
    
    private var buttonEvents: [UIButton: ContentButtonNode] = Dictionary()
    private var linkEvents: [UIButton: ContentLinkNode] = Dictionary()
    
    private(set) var hiddenInputNodes: [ContentInputNode] = Array()
    private(set) var inputViewModels: [ToolPageContentInputViewModelType] = Array()
            
    let itemSpacing: CGFloat
    let scrollIsEnabled: Bool
    
    required init(node: MobileContentXmlNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, localizationServices: LocalizationServices, followUpsService: FollowUpsService, itemSpacing: CGFloat, scrollIsEnabled: Bool, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, defaultButtonBorderColor: UIColor?) {
        
        self.node = node
        self.manifest = manifest
        self.language = language
        self.translationsFileCache = translationsFileCache
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.followUpsService = followUpsService
        self.itemSpacing = itemSpacing
        self.scrollIsEnabled = scrollIsEnabled
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        self.defaultButtonBorderColor = defaultButtonBorderColor
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func render(didRenderView: ((_ mobileContentView: MobileContentView) -> Void)) {
        
        for childNode in node.children {
            if let renderedMobileContentView = recurseAndRender(node: childNode) {
                didRenderView(renderedMobileContentView)
            }
        }
    }
    
    private func recurseAndRender(node: MobileContentXmlNode) -> MobileContentView? {
        
        if let paragraphNode = node as? ContentParagraphNode {
            
            let contentStackView: ToolPageContentStackView = getContentParagraph(
                paragraphNode: paragraphNode
            )
                                    
            return MobileContentView(view: contentStackView, heightConstraintType: .constrainedToChildren)
        }
        else if let textNode = node as? ContentTextNode {
            
            let textLabel: UILabel = getContentText(
                textNode: textNode,
                fontSize: 18,
                defaultFontWeight: .regular,
                defaultTextAlignment: .left,
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
        else if let buttonNode = node as? ContentButtonNode {
            
            let button: UIButton = getContentButton(
                buttonNode: buttonNode,
                fontSize: 18,
                fontWeight: .regular,
                buttonColor: toolPageColors.primaryColor,
                borderColor: defaultButtonBorderColor,
                titleColor: buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
            
            addButtonEvent(button: button, buttonNode: buttonNode)
                        
            return MobileContentView(view: button, heightConstraintType: .equalToFrame)
        }
        else if let linkNode = node as? ContentLinkNode {
            
            let button: UIButton = getContentLink(
                linkNode: linkNode,
                fontSize: 18,
                fontWeight: .regular,
                titleColor: linkNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
            
            addLinkEvent(button: button, linkNode: linkNode)
                        
            return MobileContentView(view: button, heightConstraintType: .equalToFrame)
        }
        else if let titleNode = node as? TitleNode, let titleTextNode = titleNode.textNode {
            
            let textLabel: UILabel = getContentText(
                textNode: titleTextNode,
                fontSize: 44,
                defaultFontWeight: .regular,
                defaultTextAlignment: .center,
                textColor: titleTextNode.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )
                                    
            return MobileContentView(view: textLabel, heightConstraintType: .intrinsic)
        }
        else if let headingNode = node as? HeadingNode, let headingTextNode = headingNode.textNode {
            
            let textLabel: UILabel = getContentText(
                textNode: headingTextNode,
                fontSize: 30,
                defaultFontWeight: .regular,
                defaultTextAlignment: .left,
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
            
            return MobileContentView(view: input, heightConstraintType: .constrainedToChildren)
        }
        else if let formNode = node as? ContentFormNode {
            
            let form: ToolPageContentFormView = getContentForm(formNode: formNode)
            
            return MobileContentView(view: form, heightConstraintType: .constrainedToChildren)
        }
        
        return nil
    }
    
    // MARK: - Content Views
    
    private func getContentParagraph(paragraphNode: ContentParagraphNode) -> ToolPageContentStackView {
        
        let viewModel = ToolPageContentStackViewModel(
            node: paragraphNode,
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
            itemSpacing: 5,
            scrollIsEnabled: false,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultButtonBorderColor: defaultButtonBorderColor
        )
        
        let view = ToolPageContentStackView(viewModel: viewModel)
        
        return view
    }
        
    private func getContentButton(buttonNode: ContentButtonNode, fontSize: CGFloat, fontWeight: UIFont.Weight, buttonColor: UIColor, borderColor: UIColor?, titleColor: UIColor) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        
        button.backgroundColor = buttonColor
        if let borderColor = borderColor {
            button.layer.borderColor = borderColor.cgColor
            button.layer.borderWidth = 1
        }
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = fontService.getFont(size: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitle(buttonNode.textNode?.text, for: .normal)
        
        return button
    }
    
    private func getContentLink(linkNode: ContentLinkNode, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: 50)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = fontService.getFont(size: fontSize, weight: fontWeight)
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
        
        label.font = fontService.getFont(size: fontSize * fontScale, weight: fontWeight)
        label.text = textNode.text
        label.textColor = textColor
        label.textAlignment = textAlignment
        
        label.setLineSpacing(lineSpacing: 2)
        
        return label
    }
    
    private func getContentTabs(tabsNode: ContentTabsNode) -> ToolPageContentTabsView {
        
        let viewModel = ToolPageContentTabsViewModel(
            tabsNode: tabsNode,
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor
        )
        
        let view = ToolPageContentTabsView(viewModel: viewModel)
        
        return view
    }
    
    private func getContentInput(inputNode: ContentInputNode) -> ToolPageContentInputView {
        
        let viewModel = ToolPageContentInputViewModel(
            inputNode: inputNode,
            fontService: fontService,
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
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
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
                mobileContentEvents.followUpEventButtonTapped(followUpEventButton: FollowUpButtonEvent(triggerEventsOnFollowUpSent: triggerEvents))
            }
            else {
                for event in buttonNode.events {
                    mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
                }
            }
        }
        else if buttonNode.type == "url", let url = buttonNode.url {
            mobileContentEvents.urlButtonTapped(urlButtonEvent: UrlButtonEvent(url: url))
        }
        
        if let analyticsEventsNode = buttonNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
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
            mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
        }
        
        if let analyticsEventsNode = linkNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
