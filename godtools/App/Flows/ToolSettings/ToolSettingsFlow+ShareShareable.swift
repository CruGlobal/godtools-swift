//
//  ToolSettingsFlow+ShareShareable.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

extension ToolSettingsFlow {
    
    func getReviewShareShareableView(toolSettingsObserver: ToolSettingsObserver, shareable: ShareableDomainModel) -> UIViewController {
        
        let viewModel = ReviewShareShareableViewModel(
            stepEmitter: stepEmitter,
            toolId: toolSettingsObserver.toolId,
            shareable: shareable,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getReviewShareShareableStringsUseCase: appDiContainer.feature.shareables.domainLayer.getReviewShareShareableStringsUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase(),
            trackShareShareableTapUseCase: appDiContainer.feature.shareables.domainLayer.getTrackShareShareableTapUseCase()
        )
        
        let view = ReviewShareShareableView(viewModel: viewModel)
        
        let hostingView = AppHostingController<ReviewShareShareableView>(
            rootView: view,
            navigationBar: nil
        )
        
        hostingView.view.backgroundColor = .white
        
        return hostingView
    }
}
