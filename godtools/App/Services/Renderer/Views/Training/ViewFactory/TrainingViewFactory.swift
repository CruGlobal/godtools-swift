//
//  TrainingViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TrainingViewFactory: MobileContentPageViewFactoryType {
    
    private let translationsFileCache: TranslationsFileCache
    private let viewedTrainingTipsService: ViewedTrainingTipsService
    
    private(set) weak var flowDelegate: FlowDelegate?
        
    required init(flowDelegate: FlowDelegate, translationsFileCache: TranslationsFileCache, viewedTrainingTipsService: ViewedTrainingTipsService) {
        
        self.flowDelegate = flowDelegate
        self.translationsFileCache = translationsFileCache
        self.viewedTrainingTipsService = viewedTrainingTipsService
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
        
        let tipModel: Tip? = (renderableModel as? Tip) ?? (renderableModel as? InlineTip)?.tip
        
        if let tipModel = tipModel {
                        
            let parentIsHeader: Bool = renderableModelParent is Header
            let trainingViewType: TrainingTipViewType = parentIsHeader ? .upArrow : .rounded
            
            return getTrainingTipView(
                tipModel: tipModel,
                renderedPageContext: renderedPageContext,
                trainingTipViewType: trainingViewType
            )
        }
        else if let pageModel = renderableModel as? TipPage {
            
            let viewModel = TrainingPageViewModel(
                pageModel: pageModel,
                renderedPageContext: renderedPageContext
            )
            
            let view = TrainingPageView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
    
    private func getTrainingTipView(tipModel: Tip, renderedPageContext: MobileContentRenderedPageContext, trainingTipViewType: TrainingTipViewType) -> TrainingTipView? {
        
        guard renderedPageContext.trainingTipsEnabled else {
            return nil
        }
        
        let viewModel = TrainingTipViewModel(
            tipModel: tipModel,
            renderedPageContext: renderedPageContext,
            viewType: trainingTipViewType,
            translationsFileCache: translationsFileCache,
            viewedTrainingTipsService: viewedTrainingTipsService
        )
        
        let view = TrainingTipView(viewModel: viewModel)
        
        return view
    }
}
