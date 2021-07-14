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
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.flowDelegate = flowDelegate
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
        else if let textModel = renderableNode as? ContentTextModelType {
                          
            let viewModel = MobileContentTextViewModel(
                textModel: textModel,
                pageModel: pageModel,
                containerNode: containerNode,
                fontService: fontService
            )
            
            let view = MobileContentTextView(viewModel: viewModel)
            
            return view
        }
        else if let imageModel = renderableNode as? ContentImageModelType {
            
            let viewModel = MobileContentImageViewModel(
                imageModel: imageModel,
                pageModel: pageModel
            )
            
            let view = MobileContentImageView(viewModel: viewModel)
            
            return view            
        }
        else if let buttonModel = renderableNode as? ContentButtonModelType {
                        
            let viewModel = MobileContentButtonViewModel(
                buttonModel: buttonModel,
                pageModel: pageModel,
                containerNode: containerNode,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )

            let view = MobileContentButtonView(viewModel: viewModel)
            
            return view
        }
        else if let linkModel = renderableNode as? ContentLinkModelType {
                        
            let viewModel = MobileContentLinkViewModel(
                linkModel: linkModel,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )
            
            let view = MobileContentLinkView(viewModel: viewModel)
            
            return view
        }
        else if let headingModel = renderableNode as? HeadingModelType {
            
            let viewModel = MobileContentHeadingViewModel(
                headingModel: headingModel,
                pageModel: pageModel
            )
            
            let view = MobileContentHeadingView(viewModel: viewModel)
            
            return view
        }
        else if let titleModel = renderableNode as? TitleModelType {
                  
            let viewModel = MobileContentTitleViewModel(
                titleModel: titleModel,
                pageModel: pageModel
            )
            
            let view = MobileContentTitleView(viewModel: viewModel)
            
            return view
        }
        else if let numberModel = renderableNode as? NumberModelType {
            
            let viewModel = MobileContentNumberViewModel(
                numberModel: numberModel,
                pageModel: pageModel
            )
            
            let view = MobileContentNumberView(viewModel: viewModel)
            
            return view
        }
        else if let videoModel = renderableNode as? ContentVideoModelType {
            
            let viewModel = MobileContentEmbeddedVideoViewModel(videoModel: videoModel)
            
            let view = MobileContentEmbeddedVideoView(viewModel: viewModel)
            
            return view
        }
        else if let tabModel = renderableNode as? ContentTabModelType {
            
            let viewModel = MobileContentTabViewModel(
                tabModel: tabModel,
                pageModel: pageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentTabView(viewModel: viewModel)
            
            return view
        }
        else if let tabsModel = renderableNode as? ContentTabsModelType {

            let viewModel = MobileContentTabsViewModel(
                tabsModel: tabsModel,
                pageModel: pageModel
            )
            
            let view = MobileContentTabsView(viewModel: viewModel)
            
            return view
        }
        else if let inputModel = renderableNode as? ContentInputModelType {
            
            let viewModel = MobileContentInputViewModel(
                inputModel: inputModel,
                pageModel: pageModel,
                fontService: fontService
            )
            
            let view = MobileContentInputView(viewModel: viewModel)
            
            return view
        }
        else if let formModel = renderableNode as? ContentFormModelType {
            
            let viewModel = MobileContentFormViewModel(
                formModel: formModel,
                pageModel: pageModel
            )
            
            let view = MobileContentFormView(viewModel: viewModel)
            
            return view
        }
        else if let spacerModel = renderableNode as? ContentSpacerModelType {
                
            let viewModel = MobileContentSpacerViewModel(
                spacerModel: spacerModel,
                pageModel: pageModel
            )
            
            let view = MobileContentSpacerView(viewModel: viewModel)
            
            return view
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
