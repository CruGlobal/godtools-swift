//
//  ToolPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageViewFactory: MobileContentPageViewFactoryType {
        
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let cardJumpService: CardJumpService
    
    required init(mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices, cardJumpService: CardJumpService) {
        
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        if let cardNode = renderableNode as? CardNode, let cardsNode = cardNode.parent as? CardsNode {
            
            let viewModel = ToolPageCardViewModel(
                cardNode: cardNode,
                cardsNode: cardsNode,
                pageModel: pageModel,
                toolPageColors: ToolPageColors(pageNode: pageModel.pageNode, manifest: pageModel.manifest),
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService,
                localizationServices: localizationServices
            )
            
            let view = ToolPageCardView(viewModel: viewModel)
            
            return view
        }
        else if let callToActionNode = renderableNode as? CallToActionNode {
            
            let viewModel = ToolPageCallToActionViewModel(
                callToActionNode: callToActionNode,
                pageModel: pageModel,
                toolPageColors: ToolPageColors(pageNode: pageModel.pageNode, manifest: pageModel.manifest),
                fontService: fontService
            )
            
            let view = ToolPageCallToActionView(viewModel: viewModel)
            
            return view
        }
        else if let headerNode = renderableNode as? HeaderNode {
            
            let viewModel = ToolPageHeaderViewModel(
                headerNode: headerNode,
                pageModel: pageModel,
                toolPageColors: ToolPageColors(pageNode: pageModel.pageNode, manifest: pageModel.manifest),
                fontService: fontService
            )

            let view = ToolPageHeaderView(viewModel: viewModel)
            
            return view
        }
        else if let heroNode = renderableNode as? HeroNode {
            
            let viewModel = ToolPageHeroViewModel(
                heroNode: heroNode
            )
            
            let view = ToolPageHeroView(viewModel: viewModel)
            
            return view
        }
        else if let cardsNode = renderableNode as? CardsNode {
            
            let viewModel = ToolPageCardsViewModel(
                cardsNode: cardsNode,
                pageModel: pageModel,
                cardJumpService: cardJumpService
            )
            
            let view = ToolPageCardsView(
                viewModel: viewModel,
                safeArea: pageModel.safeArea
            )
            
            return view
        }
        else if let pageNode = renderableNode as? PageNode {
            
            // TODO: I need to fix initial positions. ~Levi
            
            let viewModel = ToolPageViewModel(
                pageNode: pageNode,
                pageModel: pageModel,
                toolPageColors: ToolPageColors(pageNode: pageNode, manifest: pageModel.manifest)
            )
            
            let view = ToolPageView(
                viewModel: viewModel,
                windowViewController: pageModel.window,
                safeArea: pageModel.safeArea
            )
            
            return view
            
            /*
            let viewModel: ToolPageViewModel = ToolPageViewModel(
                pageNode: pageNode,
                diContainer: diContainer,
                page: page,
                initialPositions: nil
            )
            
            let view = ToolPageView(
                viewModel: viewModel,
                windowViewController: <#T##UIViewController#>,
                safeArea: <#T##UIEdgeInsets#>
            )
            
            return view*/
        }
        
        return nil
    }
}
