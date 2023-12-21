//
//  ReviewShareShareableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class ReviewShareShareableViewModel: ObservableObject {
    
    private let resource: ResourceModel
    private let shareable: ShareableDomainModel
    private let getShareableImageUseCase: GetShareableImageUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
   
    private var imageToShare: UIImage?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var imagePreviewData: OptionalImageData?
    
    let shareImageButtonTitle: String
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, shareable: ShareableDomainModel, getShareableImageUseCase: GetShareableImageUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.shareable = shareable
        self.getShareableImageUseCase = getShareableImageUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.shareImageButtonTitle = localizationServices.stringForSystemElseEnglish(key: "toolSettings.shareImagePreview.shareImageButton.title")
        
        getShareableImageUseCase
            .getShareableImagePublisher(shareable: shareable)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ShareableImageDomainModel?) in
                                
                if let imageData = domainModel?.imageData, let uiImage = UIImage(data: imageData) {
                         
                    self?.imageToShare = uiImage
                    
                    self?.imagePreviewData = OptionalImageData(
                        image: Image(uiImage: uiImage),
                        imageIdForAnimationChange: domainModel?.dataModelId
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    private func trackShareImageTappedAnalytics() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareShareable,
            siteSection: resource.abbreviation,
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.shareableId: shareable.dataModelId]
        )
    }
}

// MARK: - Inputs

extension ReviewShareShareableViewModel {
    
    func closeTapped() {
        
        flowDelegate?.navigate(step: .closeTappedFromReviewShareShareable)
    }
    
    func shareImageTapped() {
        
        guard let imageToShare = self.imageToShare else {
            return
        }
        
        flowDelegate?.navigate(step: .shareImageTappedFromReviewShareShareable(shareImage: imageToShare))
        trackShareImageTappedAnalytics()
    }
}
