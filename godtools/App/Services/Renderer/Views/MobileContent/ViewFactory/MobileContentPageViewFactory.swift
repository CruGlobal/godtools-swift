//
//  MobileContentPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentPageViewFactory: MobileContentPageViewFactoryType {
    
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let deepLinkingService: DeepLinkingServiceType
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, deepLinkingService: DeepLinkingServiceType) {
        
        self.flowDelegate = flowDelegate
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.deepLinkingService = deepLinkingService
    }
    
    func viewForRenderableModel(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        if let paragraphModel = renderableModel as? ContentParagraphModelType {
        
            let viewModel = MobileContentParagraphViewModel(
                paragraphModel: paragraphModel,
                rendererPageModel: rendererPageModel,
                containerModel: containerModel
            )
            
            let view = MobileContentParagraphView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 5, scrollIsEnabled: false)
            
            return view
        }
        else if let textModel = renderableModel as? ContentTextModelType {
                          
            let viewModel = MobileContentTextViewModel(
                textModel: textModel,
                rendererPageModel: rendererPageModel,
                containerModel: containerModel,
                fontService: fontService
            )
            
            let view = MobileContentTextView(viewModel: viewModel)
            
            return view
        }
        else if let imageModel = renderableModel as? ContentImageModelType {
            
            let viewModel = MobileContentImageViewModel(
                imageModel: imageModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentImageView(viewModel: viewModel)
            
            return view            
        }
        else if let buttonModel = renderableModel as? ContentButtonModelType {
                        
            let viewModel = MobileContentButtonViewModel(
                buttonModel: buttonModel,
                rendererPageModel: rendererPageModel,
                containerModel: containerModel,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )

            let view = MobileContentButtonView(viewModel: viewModel)
            
            return view
        }
        else if let contentCard = renderableModel as? MultiplatformContentCard {
            
            let viewModel = MobileContentCardViewModel(
                contentCard: contentCard,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentCardView(viewModel: viewModel)
            
            return view
        }
        else if let linkModel = renderableModel as? ContentLinkModelType {
                        
            let viewModel = MobileContentLinkViewModel(
                linkModel: linkModel,
                rendererPageModel: rendererPageModel,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )
            
            let view = MobileContentLinkView(viewModel: viewModel)
            
            return view
        }
        else if let cardCollectionPageCard = renderableModel as? CardCollectionPage.Card {
            
            let viewModel = MobileContentCardCollectionPageCardViewModel(
                card: cardCollectionPageCard
            )
            
            let view = MobileContentCardCollectionPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let contentPage = renderableModel as? MultiplatformContentPage {
            
            guard let flowDelegate = self.flowDelegate else {
                // TODO: Return an error here if flowDelegate is null for some reason. ~Levi
                return nil
            }
            
            let viewModel = MobileContentContentPageViewModel(
                flowDelegate: flowDelegate,
                contentPage: contentPage,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkingService
            )
            
            let view = MobileContentContentPageView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 20)
            
            return view
        }
        else if let cardCollectionPage = renderableModel as? MultiplatformCardCollectionPage {
            
            guard let flowDelegate = self.flowDelegate else {
                // TODO: Return an error here if flowDelegate is null for some reason. ~Levi
                return nil
            }
            
            let viewModel = MobileContentCardCollectionPageViewModel(
                flowDelegate: flowDelegate,
                cardCollectionPage: cardCollectionPage,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkingService
            )
            
            let view = MobileContentCardCollectionPageView(viewModel: viewModel)
            
            return view
        }
        else if let headingModel = renderableModel as? HeadingModelType {
            
            let viewModel = MobileContentHeadingViewModel(
                headingModel: headingModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentHeadingView(viewModel: viewModel)
            
            return view
        }
        else if let contentModel = renderableModel as? ContentModelType {
            
            return MobileContentStackView(
                contentInsets: contentModel.contentInsets,
                itemSpacing: contentModel.itemSpacing,
                scrollIsEnabled: contentModel.scrollIsEnabled
            )
        }
        else if let titleModel = renderableModel as? TitleModelType {
                  
            let viewModel = MobileContentTitleViewModel(
                titleModel: titleModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentTitleView(viewModel: viewModel)
            
            return view
        }
        else if let numberModel = renderableModel as? NumberModelType {
            
            let viewModel = MobileContentNumberViewModel(
                numberModel: numberModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentNumberView(viewModel: viewModel)
            
            return view
        }
        else if let animationModel = renderableModel as? ContentAnimationModelType {
            
            let viewModel = MobileContentAnimationViewModel(
                animationModel: animationModel,
                rendererPageModel: rendererPageModel,
                containerModel: containerModel
            )
            
            let view = MobileContentAnimationView(viewModel: viewModel)
            
            return view
        }
        else if let videoModel = renderableModel as? ContentVideoModelType {
            
            let viewModel = MobileContentEmbeddedVideoViewModel(videoModel: videoModel)
            
            let view = MobileContentEmbeddedVideoView(viewModel: viewModel)
            
            return view
        }
        else if let tabModel = renderableModel as? ContentTabModelType {
            
            let viewModel = MobileContentTabViewModel(
                tabModel: tabModel,
                rendererPageModel: rendererPageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentTabView(viewModel: viewModel)
            
            return view
        }
        else if let tabsModel = renderableModel as? ContentTabsModelType {

            let viewModel = MobileContentTabsViewModel(
                tabsModel: tabsModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentTabsView(viewModel: viewModel)
            
            return view
        }
        else if let inputModel = renderableModel as? ContentInputModelType {
            
            let viewModel = MobileContentInputViewModel(
                inputModel: inputModel,
                rendererPageModel: rendererPageModel,
                fontService: fontService
            )
            
            let view = MobileContentInputView(viewModel: viewModel)
            
            return view
        }
        else if let formModel = renderableModel as? ContentFormModelType {
            
            let viewModel = MobileContentFormViewModel(
                formModel: formModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentFormView(viewModel: viewModel)
            
            return view
        }
        else if let spacerModel = renderableModel as? ContentSpacerModelType {
                
            let viewModel = MobileContentSpacerViewModel(
                spacerModel: spacerModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentSpacerView(viewModel: viewModel)
            
            return view
        }
        else if let headerModel = renderableModel as? ContentHeaderModelType {
            
            let viewModel = MobileContentHeaderViewModel(
                headerModel: headerModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let contentFlow = renderableModel as? GodToolsToolParser.Flow {
            
            let viewModel = MobileContentFlowViewModel(
                contentFlow: contentFlow,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentFlowView(viewModel: viewModel, itemSpacing: 16)
            
            return view
        }
        else if let contentFlowItem = renderableModel as? GodToolsToolParser.Flow.Item {
            
            let viewModel = MobileContentFlowItemViewModel(
                flowItem: contentFlowItem
            )
            
            let view = MobileContentFlowItemView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectOptionModel = renderableModel as? ContentMultiSelectOptionModelType {
            
            let viewModel = MobileContentMultiSelectOptionViewModel(
                multiSelectOptionModel: multiSelectOptionModel,
                rendererPageModel: rendererPageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentMultiSelectOptionView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectModel = renderableModel as? ContentMultiSelectModelType {
            
            let viewModel = MobileContentMultiSelectViewModel(
                multiSelectModel: multiSelectModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentMultiSelectView(viewModel: viewModel)
            
            return view
        }
        else if let sectionModel = renderableModel as? ContentSectionModelType {
            
            let viewModel = MobileContentSectionViewModel(
                sectionModel: sectionModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentSectionView(viewModel: viewModel)
            
            return view
        }
        else if let accordionModel = renderableModel as? ContentAccordionModelType {
            
            let viewModel = MobileContentAccordionViewModel(
                accordionModel: accordionModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentAccordionView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
