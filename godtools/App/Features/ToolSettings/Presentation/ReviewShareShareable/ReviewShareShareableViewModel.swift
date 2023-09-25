//
//  ReviewShareShareableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ReviewShareShareableViewModel: ObservableObject {
    
    private let imageToShare: UIImage
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let shareableImageDomainModel: ShareableImageDomainModel
    
    private weak var flowDelegate: FlowDelegate?
    
    let imagePreview: Image
    let shareImageButtonTitle: String
    
    init(flowDelegate: FlowDelegate, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, shareableImageDomainModel: ShareableImageDomainModel, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.shareableImageDomainModel = shareableImageDomainModel
        self.imageToShare = shareableImageDomainModel.image
        self.imagePreview = Image(uiImage: imageToShare)
        self.shareImageButtonTitle = localizationServices.stringForSystemElseEnglish(key: "toolSettings.shareImagePreview.shareImageButton.title")
    }
    
    private func trackShareImageTappedAnalytics() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareShareable,
            siteSection: shareableImageDomainModel.toolAbbreviation ?? "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.shareableId: shareableImageDomainModel.imageId ?? ""]
        )
    }
}

// MARK: - Inputs

extension ReviewShareShareableViewModel {
    
    func closeTapped() {
        
        flowDelegate?.navigate(step: .closeTappedFromReviewShareShareable)
    }
    
    func shareImageTapped() {
        
        flowDelegate?.navigate(step: .shareImageTappedFromReviewShareShareable(shareImage: imageToShare))
        trackShareImageTappedAnalytics()
    }
}
