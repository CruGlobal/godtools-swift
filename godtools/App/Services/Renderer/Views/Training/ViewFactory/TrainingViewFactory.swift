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
    private let deepLinkService: DeepLinkingServiceType
    private let trainingTipsEnabled: Bool
    
    private(set) weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, translationsFileCache: TranslationsFileCache, viewedTrainingTipsService: ViewedTrainingTipsService, deepLinkService: DeepLinkingServiceType, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.translationsFileCache = translationsFileCache
        self.viewedTrainingTipsService = viewedTrainingTipsService
        self.deepLinkService = deepLinkService
        self.trainingTipsEnabled = trainingTipsEnabled
    }
    
    func viewForRenderableModel(renderableModel: AnyObject, renderableModelParent: AnyObject?, rendererPageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        let tipModel: Tip? = (renderableModel as? Tip) ?? (renderableModel as? InlineTip)?.tip
        
        if let tipModel = tipModel {
                        
            let parentIsHeader: Bool = renderableModelParent is Header
            let trainingViewType: TrainingTipViewType = parentIsHeader ? .upArrow : .rounded
            
            return getTrainingTipView(
                tipModel: tipModel,
                rendererPageModel: rendererPageModel,
                trainingTipViewType: trainingViewType
            )
        }
        else if let pageModel = renderableModel as? Page {
            
            guard let flowDelegate = self.flowDelegate else {
                return nil
            }
            
            let viewModel = TrainingPageViewModel(
                flowDelegate: flowDelegate,
                pageModel: pageModel,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkService
            )
            
            let view = TrainingPageView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
    
    private func getTrainingTipView(tipModel: Tip, rendererPageModel: MobileContentRendererPageModel, trainingTipViewType: TrainingTipViewType) -> TrainingTipView? {
        
        guard trainingTipsEnabled else {
            return nil
        }
        
        let viewModel = TrainingTipViewModel(
            tipModel: tipModel,
            rendererPageModel: rendererPageModel,
            viewType: trainingTipViewType,
            translationsFileCache: translationsFileCache,
            viewedTrainingTipsService: viewedTrainingTipsService
        )
        
        let view = TrainingTipView(viewModel: viewModel)
        
        return view
    }
}
