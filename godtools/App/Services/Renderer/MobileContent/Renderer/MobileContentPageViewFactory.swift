//
//  MobileContentPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentPageViewFactory: MobileContentPageViewFactoryType {
    
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    
    required init(mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        if renderableNode is ContentParagraphNode {
        
            return MobileContentStackView(
                itemSpacing: 5,
                scrollIsEnabled: false
            )
        }
        else if let textNode = renderableNode as? ContentTextNode {
              
            // TODO: How can I add a default text alignment and text color given the page? ~Levi
            // defaultTextAlignment: defaultTextNodeTextAlignment,
            // textColor: textNode.getTextColor()?.color ?? defaultTextNodeTextColor ?? toolPageColors.textColor
            
            let viewModel = MobileContentTextViewModel(
                textNode: textNode,
                pageModel: pageModel,
                fontService: fontService,
                fontSize: 18,
                defaultFontWeight: .regular,
                defaultTextAlignment: .left,
                textColor: textNode.getTextColor()?.color ?? .black
            )
            
            let view = MobileContentTextView(viewModel: viewModel)
            
            return view
        }
        else if let imageNode = renderableNode as? ContentImageNode {
            
            let viewModel = MobileContentImageViewModel(
                imageNode: imageNode,
                pageModel: pageModel
            )
            
            let view = MobileContentImageView(viewModel: viewModel)
            
            return view            
        }
        else if let buttonNode = renderableNode as? ContentButtonNode {
            
            // TODO: Need to set default background color, title color, border color according to container. ~Levi
            
            let viewModel = MobileContentButtonViewModel(
                buttonNode: buttonNode,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                fontSize: 18,
                fontWeight: .regular,
                defaultBackgroundColor: buttonNode.getColor()?.color ?? .black,
                defaultTitleColor: buttonNode.textNode?.getTextColor()?.color ?? .black,
                defaultBorderColor: .black
            )

            let view = MobileContentButtonView(viewModel: viewModel)
            
            return view
        }
        else if let linkNode = renderableNode as? ContentLinkNode {
            
            // TODO: Need to provide back-up titleColor depending on container. ~Levi
            
            let viewModel = MobileContentLinkViewModel(
                linkNode: linkNode,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                fontSize: 18,
                fontWeight: .regular,
                titleColor: linkNode.textNode?.getTextColor()?.color ?? .black
            )
            
            let view = MobileContentLinkView(viewModel: viewModel)
            
            return view
            
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

            let viewModel = MobileContentTabsViewModel(
                tabsNode: tabsNode,
                pageModel: pageModel
            )
            
            let view = MobileContentTabsView(viewModel: viewModel)
            
            return view
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
