//
//  ShareablesDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ShareablesDomainLayerDependencies {
    
    private let dataLayer: ShareablesDataLayerDependencies
    
    init(dataLayer: ShareablesDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getShareableImageUseCase() -> GetShareableImageUseCase {
        return GetShareableImageUseCase(
            getShareableImageRepository: dataLayer.getShareableImageRepositoryInterface()
        )
    }
    
    func getShareablesUseCase() -> GetShareablesUseCase {
        return GetShareablesUseCase(
            getShareablesRepository: dataLayer.getShareablesRepositoryInterface()
        )
    }
    
    func getTrackShareShareableTapUseCase() -> TrackShareShareableTapUseCase {
        return TrackShareShareableTapUseCase(
            trackTap: dataLayer.getTrackShareShareableTap()
        )
    }
    
    func getViewReviewShareShareableUseCase() -> ViewReviewShareShareableUseCase {
        return ViewReviewShareShareableUseCase(
            getInterfaceStringsRepository: dataLayer.getReviewShareShareableInterfaceStringsRepositoryInterface()
        )
    }
}
