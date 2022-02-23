//
//  MobileContentPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import SwiftUI

class MobileContentPageViewFactory: MobileContentPageViewFactoryType {
    
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let deepLinkingService: DeepLinkingServiceType
    private let analytics: AnalyticsContainer
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, deepLinkingService: DeepLinkingServiceType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.deepLinkingService = deepLinkingService
        self.analytics = analytics
    }
    
    func viewForRenderableModel(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        if let paragraphModel = renderableModel as? Paragraph {
        
            let viewModel = MobileContentParagraphViewModel(
                paragraphModel: paragraphModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentParagraphView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 5, scrollIsEnabled: false)
            
            return view
        }
        else if let textModel = renderableModel as? MultiplatformContentText {
                       
            return getContentText(
                textModel: textModel,
                rendererPageModel: rendererPageModel,
                viewType: nil,
                additionalLabelAttributes: nil
            )
        }
        else if let imageModel = renderableModel as? GodToolsToolParser.Image {
            
            let viewModel = MobileContentImageViewModel(
                imageModel: imageModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentImageView(viewModel: viewModel)
            
            return view            
        }
        else if let buttonModel = renderableModel as? GodToolsToolParser.Button {
                        
            let viewModel = MobileContentButtonViewModel(
                buttonModel: buttonModel,
                rendererPageModel: rendererPageModel,
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
        else if let linkModel = renderableModel as? GodToolsToolParser.Link {
                        
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
                deepLinkService: deepLinkingService,
                analytics: analytics
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
                deepLinkService: deepLinkingService,
                analytics: analytics
            )
            
            let view = MobileContentCardCollectionPageView(viewModel: viewModel)
            
            return view
        }
        else if let headingModel = renderableModel as? MultiplatformHeading {
            
            let viewModel = MobileContentHeadingViewModel(
                headingModel: headingModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentHeadingView(viewModel: viewModel)
            
            return view
        }
        else if let contentModel = renderableModel as? MultiplatformContent {
            
            return MobileContentStackView(
                contentInsets: contentModel.contentInsets,
                itemSpacing: contentModel.itemSpacing,
                scrollIsEnabled: contentModel.scrollIsEnabled
            )
        }
        else if let animationModel = renderableModel as? GodToolsToolParser.Animation {
            
            let viewModel = MobileContentAnimationViewModel(
                animationModel: animationModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentAnimationView(viewModel: viewModel)
            
            return view
        }
        else if let videoModel = renderableModel as? Video {
            
            let viewModel = MobileContentEmbeddedVideoViewModel(
                videoModel: videoModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentEmbeddedVideoView(viewModel: viewModel)
            
            return view
        }
        else if let tabModel = renderableModel as? Tabs.Tab {
            
            let viewModel = MobileContentTabViewModel(
                tabModel: tabModel,
                rendererPageModel: rendererPageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentTabView(viewModel: viewModel)
            
            return view
        }
        else if let tabsModel = renderableModel as? Tabs {

            let viewModel = MobileContentTabsViewModel(
                tabsModel: tabsModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentTabsView(viewModel: viewModel)
            
            return view
        }
        else if let inputModel = renderableModel as? Input {
            
            let viewModel = MobileContentInputViewModel(
                inputModel: inputModel,
                rendererPageModel: rendererPageModel,
                fontService: fontService
            )
            
            let view = MobileContentInputView(viewModel: viewModel)
            
            return view
        }
        else if let formModel = renderableModel as? GodToolsToolParser.Form {
            
            let viewModel = MobileContentFormViewModel(
                formModel: formModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentFormView(viewModel: viewModel)
            
            return view
        }
        else if let spacerModel = renderableModel as? GodToolsToolParser.Spacer {
                
            let viewModel = MobileContentSpacerViewModel(
                spacerModel: spacerModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentSpacerView(viewModel: viewModel)
            
            return view
        }
        else if let headerModel = renderableModel as? MultiplatformContentHeader {
            
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
        else if let multiSelectOptionModel = renderableModel as? Multiselect.Option {
            
            let viewModel = MobileContentMultiSelectOptionViewModel(
                multiSelectOptionModel: multiSelectOptionModel,
                rendererPageModel: rendererPageModel,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentMultiSelectOptionView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectModel = renderableModel as? Multiselect {
            
            let viewModel = MobileContentMultiSelectViewModel(
                multiSelectModel: multiSelectModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentMultiSelectView(viewModel: viewModel)
            
            return view
        }
        else if let sectionModel = renderableModel as? Accordion.Section {
            
            let viewModel = MobileContentAccordionSectionViewModel(
                sectionModel: sectionModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentAccordionSectionView(viewModel: viewModel)
            
            return view
        }
        else if let accordionModel = renderableModel as? Accordion {
            
            let viewModel = MobileContentAccordionViewModel(
                accordionModel: accordionModel,
                rendererPageModel: rendererPageModel
            )
            
            let view = MobileContentAccordionView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
    
    func getContentText(textModel: MultiplatformContentText, rendererPageModel: MobileContentRendererPageModel, viewType: MobileContentTextView.ViewType?, additionalLabelAttributes: MobileContentTextLabelAttributes?) -> MobileContentTextView {
        
        let viewModel = MobileContentTextViewModel(
            textModel: textModel,
            rendererPageModel: rendererPageModel,
            fontService: fontService
        )
        
        let view = MobileContentTextView(
            viewModel: viewModel,
            viewType: viewType,
            additionalLabelAttributes: additionalLabelAttributes
        )
        
        return view
    }
}
