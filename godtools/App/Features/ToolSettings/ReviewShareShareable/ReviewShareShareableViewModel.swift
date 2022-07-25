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
    
    private weak var flowDelegate: FlowDelegate?
    private let analytics: AnalyticsContainer
    
    let shareableImageModel: ShareableImageModel
    let imagePreview: Image
    let shareImageButtonTitle: String
    
    init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer, shareableImageModel: ShareableImageModel, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        self.shareableImageModel = shareableImageModel
        self.imageToShare = shareableImageModel.image
        self.imagePreview = Image(uiImage: imageToShare)
        self.shareImageButtonTitle = localizationServices.stringForMainBundle(key: "toolSettings.shareImagePreview.shareImageButton.title")
    }
    
    func closeTapped() {
        
        flowDelegate?.navigate(step: .closeTappedFromReviewShareShareable)
    }
    
    func shareImageTapped() {
        
        flowDelegate?.navigate(step: .shareImageTappedFromReviewShareShareable(shareImage: imageToShare))
        trackShareImageTappedAnalytics()
    }
    
    func trackShareImageTappedAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareShareable,
            siteSection: shareableImageModel.toolAbbreviation ?? "",
            siteSubSection: "",
            url: nil,
            data: [AnalyticsConstants.Keys.shareableId: shareableImageModel.imageId ?? ""]
        ))
    }
}
