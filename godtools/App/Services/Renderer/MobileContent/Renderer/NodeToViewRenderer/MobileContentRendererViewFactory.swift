//
//  MobileContentRendererViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/18/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentRendererViewFactory {
    
    private let diContainer: MobileContentRendererDiContainer
    
    required init(diContainer: MobileContentRendererDiContainer) {
        
        self.diContainer = diContainer
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode) -> MobileContentRenderableView? {
        
        if let paragraphNode = renderableNode as? ContentParagraphNode {
        
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
        }
        else if let textNode = renderableNode as? ContentTextNode {
              
            /*
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
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let imageNode = renderableNode as? ContentImageNode {
            
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
        else if let buttonNode = renderableNode as? ContentButtonNode {
            
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
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let linkNode = renderableNode as? ContentLinkNode {
            
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
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let titleNode = renderableNode as? TitleNode, let textNode = titleNode.textNode {
                  
            /*
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
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let headingNode = renderableNode as? HeadingNode, let textNode = headingNode.textNode {
            
            /*
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
            
            return MobileContentStackRenderedView(view: view, heightConstraintType: .constrainedToChildren)*/
        }
        else if let tabsNode = renderableNode as? ContentTabsNode {

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
        else if let inputNode = renderableNode as? ContentInputNode {
            
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
        else if let formNode = renderableNode as? ContentFormNode {
            
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
        else if renderableNode is ContentSpacerNode {
            
            //return MobileContentStackRenderedView(view: MobileContentSpacerView(), heightConstraintType: .spacer)
        }
        
        return nil
    }
}
