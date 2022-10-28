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
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let shareableImageDomainModel: ShareableImageDomainModel
    
    private weak var flowDelegate: FlowDelegate?
    
    let imagePreview: Image
    let shareImageButtonTitle: String
    
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, shareableImageDomainModel: ShareableImageDomainModel, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.shareableImageDomainModel = shareableImageDomainModel
        self.imageToShare = shareableImageDomainModel.image
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
    
    private func trackShareImageTappedAnalytics() {
        
        let trackAction = TrackActionModel(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareShareable,
            siteSection: shareableImageDomainModel.toolAbbreviation ?? "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [AnalyticsConstants.Keys.shareableId: shareableImageDomainModel.imageId ?? ""]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
