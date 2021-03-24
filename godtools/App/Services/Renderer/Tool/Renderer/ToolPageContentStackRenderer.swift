//
//  ToolPageContentStackRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 11/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

// TODO: Remove this class. ~Levi
class ToolPageContentStackRenderer: MobileContentStackViewRendererType {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let diContainer: ToolPageDiContainer
    private let node: MobileContentXmlNode
    private let toolPageColors: ToolPageColors
    private let defaultTextNodeTextColor: UIColor?
    private let defaultTextNodeTextAlignment: NSTextAlignment
    private let defaultButtonBorderColor: UIColor?
    
    private weak var rootContentStackRenderer: ToolPageContentStackRenderer?
        
    let didRenderContentFormSignal: SignalValue<MobileContentFormView> = SignalValue()
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
    }
    
    deinit {

    }
    
    func render(didRenderView: ((_ renderedView: MobileContentStackRenderedView) -> Void)) {
                        
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
        
            // TODO: Fix this for new renderer changes. ~Levi
            /*
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
                                                         
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
            return nil
        }
        else if let textNode = node as? ContentTextNode {
              
            /*
            let viewModel = MobileContentTextViewModel(
                textNode: textNode,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                fontService: diContainer.fontService,
                fontSize: 18,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            )

            let view = MobileContentTextView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let imageNode = node as? ContentImageNode {
            
            /*
            guard imageNode.isRenderable else {
                return nil
            }
            
            let viewModel = MobileContentImageViewModel(
                imageNode: imageNode,
                mobileContentEvents: diContainer.mobileContentEvents,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                languageDirection: diContainer.language.languageDirection
            )
            
            let view = MobileContentImageView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let trainingTipNode = node as? TrainingTipNode {
            
            /*
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
                        
            rootContentStackRenderer.didRenderTrainingTipsSignal.accept()
            
            let tipSize: CGFloat = 50
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .equalToSize(size: CGSize(width: tipSize, height: tipSize)))*/
        }
        else if let buttonNode = node as? ContentButtonNode {
            
            /*
            let viewModel = MobileContentButtonViewModel(
                buttonNode: buttonNode,
                mobileContentEvents: diContainer.mobileContentEvents,
                mobileContentAnalytics: diContainer.mobileContentAnalytics,
                fontService: diContainer.fontService,
                fontSize: 18,
                fontWeight: .regular,
                defaultBackgroundColor: buttonNode.getColor()?.color ?? toolPageColors.primaryColor,
                defaultTitleColor: buttonNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor,
                defaultBorderColor: defaultButtonBorderColor
            )
            
            let view = MobileContentButtonView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
            */
        }
        else if let linkNode = node as? ContentLinkNode {
            
            /*
            let viewModel = MobileContentLinkViewModel(
                linkNode: linkNode,
                mobileContentEvents: diContainer.mobileContentEvents,
                mobileContentAnalytics: diContainer.mobileContentAnalytics,
                fontService: diContainer.fontService,
                fontSize: 18,
                fontWeight: .regular,
                titleColor: linkNode.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
            )
            
            let view = MobileContentLinkView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)
            */
        }
        else if let fallbackNode = node as? ContentFallbackNode {
            
            var nodeToRender: MobileContentXmlNode?
            
            for childNode in fallbackNode.children {
                
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
        else if let titleNode = node as? TitleNode, let textNode = titleNode.textNode {
                
            /*
            let viewModel = MobileContentTextViewModel(
                textNode: textNode,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                fontService: diContainer.fontService,
                fontSize: 44,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? toolPageColors.primaryTextColor
            )

            let view = MobileContentTextView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let headingNode = node as? HeadingNode, let textNode = headingNode.textNode {
            
            /*
            let viewModel = MobileContentTextViewModel(
                textNode: textNode,
                manifestResourcesCache: diContainer.manifestResourcesCache,
                fontService: diContainer.fontService,
                fontSize: 30,
                defaultFontWeight: .regular,
                defaultTextAlignment: defaultTextNodeTextAlignment,
                textColor: textNode.getTextColor()?.color ?? toolPageColors.primaryColor
            )

            let view = MobileContentTextView(viewModel: viewModel)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let tabsNode = node as? ContentTabsNode {

            /*
            let viewModel = MobileContentTabsViewModel(
                tabsNode: tabsNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = MobileContentTabsView(viewModel: viewModel)
                                    
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let inputNode = node as? ContentInputNode {
            
            /*
            guard inputNode.type != "hidden" else {
                rootContentStackRenderer.didRenderHiddenContentInputSignal.accept(value: inputNode)
                return nil
            }
            
            let viewModel = MobileContentInputViewModel(
                inputNode: inputNode,
                fontService: diContainer.fontService,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = MobileContentInputView(viewModel: viewModel)
            
            let renderedInput = ToolPageRenderedContentInput(viewModel: viewModel, view: view)
            
            rootContentStackRenderer.didRenderContentInputSignal.accept(value: renderedInput)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let formNode = node as? ContentFormNode {
            
            /*
            let viewModel = MobileContentFormViewModel(
                formNode: formNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: defaultTextNodeTextColor
            )
            
            let view = MobileContentFormView(viewModel: viewModel)
                        
            rootContentStackRenderer.didRenderContentFormSignal.accept(value: view)
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if node is ContentSpacerNode {
            
            return MobileContentStackRenderedView(view: MobileContentSpacerView(), heightConstraintType: .spacer)
        }
        
        return nil
    }
}
