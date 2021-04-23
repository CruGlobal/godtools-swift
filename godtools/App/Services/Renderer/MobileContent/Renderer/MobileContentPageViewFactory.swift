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
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
        if renderableNode is ContentParagraphNode {
        
            return MobileContentStackView(
                itemHorizontalInsets: 0,
                itemSpacing: 5,
                scrollIsEnabled: false
            )
        }
        else if let textNode = renderableNode as? ContentTextNode {
                          
            let viewModel = MobileContentTextViewModel(
                textNode: textNode,
                pageModel: pageModel,
                containerNode: containerNode,
                fontService: fontService
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
                        
            let viewModel = MobileContentButtonViewModel(
                buttonNode: buttonNode,
                pageModel: pageModel,
                containerNode: containerNode,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )

            let view = MobileContentButtonView(viewModel: viewModel)
            
            return view
        }
        else if let linkNode = renderableNode as? ContentLinkNode {
                        
            let viewModel = MobileContentLinkViewModel(
                linkNode: linkNode,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )
            
            let view = MobileContentLinkView(viewModel: viewModel)
            
            return view
        }
        else if let headingNode = renderableNode as? HeadingNode {
            
            let viewModel = MobileContentHeadingViewModel(
                headingNode: headingNode,
                pageModel: pageModel
            )
            
            let view = MobileContentHeadingView(viewModel: viewModel)
            
            return view
        }
        else if let titleNode = renderableNode as? TitleNode {
                  
            let viewModel = MobileContentTitleViewModel(
                titleNode: titleNode,
                pageModel: pageModel
            )
            
            let view = MobileContentTitleView(viewModel: viewModel)
            
            return view
        }
        else if let numberNode = renderableNode as? NumberNode {
            
            let viewModel = MobileContentNumberViewModel(
                numberNode: numberNode,
                pageModel: pageModel
            )
            
            let view = MobileContentNumberView(viewModel: viewModel)
            
            return view
        }
        else if let tabNode = renderableNode as? ContentTabNode {
            
            let viewModel = MobileContentTabViewModel(
                tabNode: tabNode,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentTabView(viewModel: viewModel)
            
            return view
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
            
            let viewModel = MobileContentInputViewModel(
                inputNode: inputNode,
                pageModel: pageModel,
                fontService: fontService
            )
            
            let view = MobileContentInputView(viewModel: viewModel)
            
            return view
        }
        else if let formNode = renderableNode as? ContentFormNode {
            
            let viewModel = MobileContentFormViewModel(
                formNode: formNode,
                pageModel: pageModel
            )
            
            let view = MobileContentFormView(viewModel: viewModel)
            
            return view
        }
        else if renderableNode is ContentSpacerNode {
                
            return MobileContentSpacerView()
        }
        else if let headerNode = renderableNode as? ContentHeaderNode {
            
            let viewModel = MobileContentHeaderViewModel(
                headerNode: headerNode,
                pageModel: pageModel
            )
            
            let view = MobileContentHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let sectionNode = renderableNode as? ContentSectionNode {
            
            let viewModel = MobileContentSectionViewModel(
                sectionNode: sectionNode,
                pageModel: pageModel
            )
            
            let view = MobileContentSectionView(viewModel: viewModel)
            
            return view
        }
        else if renderableNode is ContentAccordionNode {
            
            let viewModel = MobileContentAccordionViewModel()
            
            let view = MobileContentAccordionView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
