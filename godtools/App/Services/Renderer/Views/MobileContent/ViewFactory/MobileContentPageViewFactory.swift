//
//  MobileContentPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import SwiftUI

class MobileContentPageViewFactory: MobileContentPageViewFactoryType {
    
    private let mobileContentAnalytics: MobileContentRendererAnalytics
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
        
    init(
        mobileContentAnalytics: MobileContentRendererAnalytics,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    ) {
        
        self.mobileContentAnalytics = mobileContentAnalytics
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> LegacyMobileContentView? {
        
        if let paragraphModel = renderableModel as? Paragraph {
        
            let viewModel = MobileContentParagraphViewModel(
                paragraphModel: paragraphModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentParagraphView(viewModel: viewModel)
            
            return view
        }
        else if let textModel = renderableModel as? GodToolsShared.Text {
                       
            return getContentText(
                textModel: textModel,
                renderedPageContext: renderedPageContext,
                viewType: nil,
                additionalLabelAttributes: nil
            )
        }
        else if let imageModel = renderableModel as? GodToolsShared.Image {
            
            let viewModel = MobileContentImageViewModel(
                imageModel: imageModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentImageView(viewModel: viewModel)
            
            return view            
        }
        else if let buttonModel = renderableModel as? GodToolsShared.Button {
                        
            let viewModel = MobileContentButtonViewModel(
                buttonModel: buttonModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )

            let view = LegacyMobileContentButtonView(viewModel: viewModel)
            
            return view
        }
        else if let contentCard = renderableModel as? Card {
            
            let viewModel = MobileContentCardViewModel(
                cardModel: contentCard,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentCardView(viewModel: viewModel)
            
            return view
        }
        else if let linkModel = renderableModel as? GodToolsShared.Link {
                        
            let viewModel = MobileContentLinkViewModel(
                linkModel: linkModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentLinkView(viewModel: viewModel)
            
            return view
        }
        else if let cardCollectionPageCard = renderableModel as? CardCollectionPage.Card {
            
            let viewModel = MobileContentCardCollectionPageCardViewModel(
                card: cardCollectionPageCard,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentCardCollectionPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let contentPage = renderableModel as? ContentPage {
            
            let viewModel = MobileContentContentPageViewModel(
                contentPage: contentPage,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase
            )
            
            let view = LegacyMobileContentContentPageView(viewModel: viewModel)
            
            return view
        }
        else if let cardCollectionPage = renderableModel as? CardCollectionPage {

            let viewModel = MobileContentCardCollectionPageViewModel(
                cardCollectionPage: cardCollectionPage,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase
            )
            
            let view = LegacyMobileContentCardCollectionPageView(viewModel: viewModel)
            
            return view
        }
        else if let headingModel = renderableModel as? MultiplatformHeading {
            
            let viewModel = MobileContentHeadingViewModel(
                headingModel: headingModel.text,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentHeadingView(viewModel: viewModel)
            
            return view
        }
        else if let contentModel = renderableModel as? MultiplatformContent {
            
            let viewModel = MobileContentViewModel(
                baseModels: contentModel.content,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            return LegacyMobileContentStackView(
                viewModel: viewModel,
                contentInsets: contentModel.contentInsets,
                scrollIsEnabled: contentModel.scrollIsEnabled
            )
        }
        else if let animationModel = renderableModel as? GodToolsShared.Animation {
            
            let viewModel = MobileContentAnimationViewModel(
                animationModel: animationModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentAnimationView(viewModel: viewModel)
            
            return view
        }
        else if let videoModel = renderableModel as? Video {
            
            let viewModel = MobileContentEmbeddedVideoViewModel(
                videoModel: videoModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentEmbeddedVideoView(viewModel: viewModel)
            
            return view
        }
        else if let tabModel = renderableModel as? Tabs.Tab {
            
            let viewModel = MobileContentTabViewModel(
                tabModel: tabModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentTabView(viewModel: viewModel)
            
            return view
        }
        else if let tabsModel = renderableModel as? Tabs {

            let viewModel = MobileContentTabsViewModel(
                tabsModel: tabsModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentTabsView(viewModel: viewModel)
            
            return view
        }
        else if let inputModel = renderableModel as? Input {
            
            let viewModel = MobileContentInputViewModel(
                inputModel: inputModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentInputView(viewModel: viewModel)
            
            return view
        }
        else if let formModel = renderableModel as? GodToolsShared.Form {
            
            let viewModel = MobileContentFormViewModel(
                formModel: formModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentFormView(viewModel: viewModel)
            
            return view
        }
        else if let spacerModel = renderableModel as? GodToolsShared.Spacer {
                
            let viewModel = MobileContentSpacerViewModel(
                spacerModel: spacerModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentSpacerView(viewModel: viewModel)
            
            return view
        }
        else if let headerModel = renderableModel as? MultiplatformContentHeader {
            
            let viewModel = MobileContentHeaderViewModel(
                headerModel: headerModel.text,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let contentFlow = renderableModel as? GodToolsShared.Flow {
            
            let viewModel = MobileContentFlowViewModel(
                contentFlow: contentFlow,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentFlowView(viewModel: viewModel)
            
            return view
        }
        else if let contentFlowItem = renderableModel as? GodToolsShared.Flow.Item {
            
            let viewModel = MobileContentFlowItemViewModel(
                flowItem: contentFlowItem,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentFlowItemView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectOptionModel = renderableModel as? Multiselect.Option {
            
            let viewModel = MobileContentMultiSelectOptionViewModel(
                multiSelectOptionModel: multiSelectOptionModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentMultiSelectOptionView(viewModel: viewModel)
            
            return view
        }
        else if let multiSelectModel = renderableModel as? Multiselect {
            
            let viewModel = MobileContentMultiSelectViewModel(
                multiSelectModel: multiSelectModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentMultiSelectView(viewModel: viewModel)
            
            return view
        }
        else if let sectionModel = renderableModel as? Accordion.Section {
            
            let viewModel = MobileContentAccordionSectionViewModel(
                sectionModel: sectionModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentAccordionSectionView(viewModel: viewModel)
            
            return view
        }
        else if let accordionModel = renderableModel as? Accordion {
            
            let viewModel = MobileContentAccordionViewModel(
                accordionModel: accordionModel,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics
            )
            
            let view = LegacyMobileContentAccordionView(viewModel: viewModel)
            
            return view
        }
        else if let pageCollection = renderableModel as? PageCollectionPage {
            
            let viewModel = MobileContentPageCollectionViewModel(
                pageCollectionPage: pageCollection,
                renderedPageContext: renderedPageContext,
                mobileContentAnalytics: mobileContentAnalytics,
                trackScreenViewAnalyticsUseCase: trackScreenViewAnalyticsUseCase
            )
            
            let view = LegacyMobileContentPageCollectionView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
    
    func getContentText(textModel: GodToolsShared.Text, renderedPageContext: MobileContentRenderedPageContext, viewType: LegacyMobileContentTextView.ViewType?, additionalLabelAttributes: MobileContentTextLabelAttributes?) -> LegacyMobileContentTextView {
        
        let viewModel = MobileContentTextViewModel(
            textModel: textModel,
            renderedPageContext: renderedPageContext,
            mobileContentAnalytics: mobileContentAnalytics
        )
        
        let view = LegacyMobileContentTextView(
            viewModel: viewModel,
            viewType: viewType,
            additionalLabelAttributes: additionalLabelAttributes
        )
        
        return view
    }
}
