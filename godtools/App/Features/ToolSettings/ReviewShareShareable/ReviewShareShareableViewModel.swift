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
    
    let imagePreview: Image
    let imageId: String?
    let shareImageButtonTitle: String
    
    init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer, imageToShare: UIImage, imageId: String?, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        self.imageToShare = imageToShare
        self.imagePreview = Image(uiImage: imageToShare)
        self.imageId = imageId
        self.shareImageButtonTitle = localizationServices.stringForMainBundle(key: "toolSettings.shareImagePreview.shareImageButton.title")
    }
    
    func closeTapped() {
        
        flowDelegate?.navigate(step: .closeTappedFromReviewShareShareable)
    }
    
    func shareImageTapped() {
        
        flowDelegate?.navigate(step: .shareImageTappedFromReviewShareShareable(shareImage: imageToShare))
    }
}
