//
//  ToolSharer.swift
//  godtools
//
//  Created by Rachael Skeath on 10/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

protocol ToolSharer { }

extension Flow where Self: ToolSharer {
    
    func getShareToolView(viewShareToolDomainModel: ViewShareToolDomainModel, toolId: String, toolAnalyticsAbbreviation: String, pageNumber: Int) -> UIViewController {
                
        let viewModel = ShareToolViewModel(
            viewShareToolDomainModel: viewShareToolDomainModel,
            toolId: toolId,
            toolAnalyticsAbbreviation: toolAnalyticsAbbreviation,
            pageNumber: pageNumber,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ShareToolView(viewModel: viewModel)
        
        return view.controller
    }
}
