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
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let viewedTrainingTipsService: ViewedTrainingTipsService
    private let trainingTipsEnabled: Bool
    
    required init(translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, viewedTrainingTipsService: ViewedTrainingTipsService, trainingTipsEnabled: Bool) {
        
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.viewedTrainingTipsService = viewedTrainingTipsService
        self.trainingTipsEnabled = trainingTipsEnabled
    }
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        if let trainingTipNode = renderableNode as? TrainingTipNode {
            
            guard let trainingTipId = trainingTipNode.id, !trainingTipId.isEmpty, trainingTipsEnabled else {
                return nil
            }
            
            let viewModel = TrainingTipViewModel(
                trainingTipId: trainingTipId,
                pageModel: pageModel,
                viewType: .rounded,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                viewedTrainingTipsService: viewedTrainingTipsService
            )
            
            let view = TrainingTipView(viewModel: viewModel)
            
            return view
        }
        else if let pageNode = renderableNode as? PageNode {
            
            let viewModel = TrainingPageViewModel(
                pageNode: pageNode,
                pageModel: pageModel
            )
            
            let view = TrainingPageView(viewModel: viewModel)
            
            return view
        }
        
        return nil
    }
}
