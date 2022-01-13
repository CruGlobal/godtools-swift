//
//  TrainingViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

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
    
    func viewForRenderableModel(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        if let trainingTipModel = renderableModel as? TrainingTipModelType {
            
            let parentIsHeader: Bool = renderableModelParent is HeaderModelType
            let trainingViewType: TrainingTipViewType = parentIsHeader ? .upArrow : .rounded
            
            return getTrainingTipView(
                tipModel: trainingTipModel.tip,
                rendererPageModel: rendererPageModel,
                trainingTipViewType: trainingViewType
            )
        }
        else if let pageModel = renderableModel as? PageModelType {
            
            let viewModel = TrainingPageViewModel(
                flowDelegate: getFlowDelegate(),
                pageModel: pageModel,
                rendererPageModel: rendererPageModel,
                deepLinkService: deepLinkService
            )
            
            let view = TrainingPageView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
    
    private func getTrainingTipView(tipModel: TipModelType, rendererPageModel: MobileContentRendererPageModel, trainingTipViewType: TrainingTipViewType) -> TrainingTipView? {
        
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
