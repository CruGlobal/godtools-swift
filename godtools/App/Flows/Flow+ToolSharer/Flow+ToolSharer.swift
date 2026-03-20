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
    
    // TODO: Need to create a Flow so flow delegation can be shared. ~Levi
    
    func getShareToolView(flowDelegate: FlowDelegate, strings: ShareToolStringsDomainModel, toolId: String, toolAnalyticsAbbreviation: String, pageNumber: Int) -> UIViewController {
                
        let viewModel = ShareToolViewModel(
            flowDelegate: flowDelegate,
            strings: strings,
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
