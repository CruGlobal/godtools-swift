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
    
    private let mobileContentAnalytics: MobileContentRendererAnalytics
    private let fontService: FontService
    private let analytics: AnalyticsContainer
        
    init(mobileContentAnalytics: MobileContentRendererAnalytics, fontService: FontService, analytics: AnalyticsContainer) {
        
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.analytics = analytics
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        if let paragraphModel = renderableModel as? Paragraph {
        
            let viewModel = MobileContentParagraphViewModel(
                paragraphModel: paragraphModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentParagraphView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 5, scrollIsEnabled: false)
            
            return view
        }
        else if let textModel = renderableModel as? GodToolsToolParser.Text {
                       
            return getContentText(
                textModel: textModel,
                renderedPageContext: renderedPageContext,
                viewType: nil,
                additionalLabelAttributes: nil
            )
        }
        else if let imageModel = renderableModel as? GodToolsToolParser.Image {
            
            let viewModel = MobileContentImageViewModel(
                imageModel: imageModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentImageView(viewModel: viewModel)
            
            return view            
        }
        else if let buttonModel = renderableModel as? GodToolsToolParser.Button {
                        
            let viewModel = MobileContentButtonViewModel(
                buttonModel: buttonModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )

            let view = MobileContentButtonView(viewModel: viewModel)
            
            return view
        }
        else if let contentCard = renderableModel as? Card {
            
            let viewModel = MobileContentCardViewModel(
                cardModel: contentCard,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentCardView(viewModel: viewModel)
            
            return view
        }
        else if let linkModel = renderableModel as? GodToolsToolParser.Link {
                        
            let viewModel = MobileContentLinkViewModel(
                linkModel: linkModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )
            
            let view = MobileContentLinkView(viewModel: viewModel)
            
            return view
        }
        else if let cardCollectionPageCard = renderableModel as? CardCollectionPage.Card {
            
            let viewModel = MobileContentCardCollectionPageCardViewModel(
                card: cardCollectionPageCard,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentCardCollectionPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let contentPage = renderableModel as? ContentPage {
            
            let viewModel = MobileContentContentPageViewModel(
                contentPage: contentPage,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                analytics: analytics
            )
            
            let view = MobileContentContentPageView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 20)
            
            return view
        }
        else if let cardCollectionPage = renderableModel as? CardCollectionPage {

            let viewModel = MobileContentCardCollectionPageViewModel(
                cardCollectionPage: cardCollectionPage,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                analytics: analytics
            )
            
            let view = MobileContentCardCollectionPageView(viewModel: viewModel)
            
            return view
        }
        else if let headingModel = renderableModel as? MultiplatformHeading {
            
            let viewModel = MobileContentHeadingViewModel(
                headingModel: headingModel.text,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentHeadingView(viewModel: viewModel)
            
            return view
        }
        else if let contentModel = renderableModel as? MultiplatformContent {
            
            let viewModel = MobileContentViewModel(
                baseModels: contentModel.content,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            return MobileContentStackView(
                viewModel: viewModel,
                contentInsets: contentModel.contentInsets,
                itemSpacing: contentModel.itemSpacing,
                scrollIsEnabled: contentModel.scrollIsEnabled
            )
        }
        else if let animationModel = renderableModel as? GodToolsToolParser.Animation {
            
            let viewModel = MobileContentAnimationViewModel(
                animationModel: animationModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentAnimationView(viewModel: viewModel)
            
            return view
        }
        else if let videoModel = renderableModel as? Video {
            
            let viewModel = MobileContentEmbeddedVideoViewModel(
                videoModel: videoModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentEmbeddedVideoView(viewModel: viewModel)
            
            return view
        }
        else if let tabModel = renderableModel as? Tabs.Tab {
            
            let viewModel = MobileContentTabViewModel(
                tabModel: tabModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentTabView(viewModel: viewModel)
            
            return view
        }
        else if let tabsModel = renderableModel as? Tabs {

            let viewModel = MobileContentTabsViewModel(
                tabsModel: tabsModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentTabsView(viewModel: viewModel)
            
            return view
        }
        else if let inputModel = renderableModel as? Input {
            
            let viewModel = MobileContentInputViewModel(
                inputModel: inputModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )
            
            let view = MobileContentInputView(viewModel: viewModel)
            
            return view
        }
        else if let formModel = renderableModel as? GodToolsToolParser.Form {
            
            let viewModel = MobileContentFormViewModel(
                formModel: formModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentFormView(viewModel: viewModel)
            
            return view
        }
        else if let spacerModel = renderableModel as? GodToolsToolParser.Spacer {
                
            let viewModel = MobileContentSpacerViewModel(
                spacerModel: spacerModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentSpacerView(viewModel: viewModel)
            
            return view
        }
        else if let headerModel = renderableModel as? MultiplatformContentHeader {
            
            let viewModel = MobileContentHeaderViewModel(
                headerModel: headerModel.text,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let contentFlow = renderableModel as? GodToolsToolParser.Flow {
            
            let viewModel = MobileContentFlowViewModel(
                contentFlow: contentFlow,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentFlowView(viewModel: viewModel)
            
            return view
        }
        else if let contentFlowItem = renderableModel as? GodToolsToolParser.Flow.Item {
            
            let viewModel = MobileContentFlowItemViewModel(
                flowItem: contentFlowItem,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentFlowItemView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectOptionModel = renderableModel as? Multiselect.Option {
            
            let viewModel = MobileContentMultiSelectOptionViewModel(
                multiSelectOptionModel: multiSelectOptionModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentMultiSelectOptionView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectModel = renderableModel as? Multiselect {
            
            let viewModel = MobileContentMultiSelectViewModel(
                multiSelectModel: multiSelectModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentMultiSelectView(viewModel: viewModel)
            
            return view
        }
        else if let sectionModel = renderableModel as? Accordion.Section {
            
            let viewModel = MobileContentAccordionSectionViewModel(
                sectionModel: sectionModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentAccordionSectionView(viewModel: viewModel)
            
            return view
        }
        else if let accordionModel = renderableModel as? Accordion {
            
            let viewModel = MobileContentAccordionViewModel(
                accordionModel: accordionModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = MobileContentAccordionView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
    
    func getContentText(textModel: GodToolsToolParser.Text, renderedPageContext: MobileContentRenderedPageContext, viewType: MobileContentTextView.ViewType?, additionalLabelAttributes: MobileContentTextLabelAttributes?) -> MobileContentTextView {
        
        let viewModel = MobileContentTextViewModel(
            textModel: textModel,
            renderedPageContext: renderedPageContext,
            mobileContentAnalytics: mobileContentAnalytics,
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
