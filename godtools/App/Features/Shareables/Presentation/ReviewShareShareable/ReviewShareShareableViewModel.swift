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
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewReviewShareShareableUseCase: ViewReviewShareShareableUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
   
    private var imageToShare: UIImage?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var imagePreviewData: OptionalImageData?
    @Published var shareImageButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, shareable: ShareableDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewReviewShareShareableUseCase: ViewReviewShareShareableUseCase, getShareableImageUseCase: GetShareableImageUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.shareable = shareable
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewReviewShareShareableUseCase = viewReviewShareShareableUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewReviewShareShareableDomainModel, Never> in
                return viewReviewShareShareableUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .sink { [weak self] (domainModel: ViewReviewShareShareableDomainModel) in
                self?.shareImageButtonTitle = domainModel.interfaceStrings.shareActionTitle
            }
            .store(in: &cancellables)
        
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
    
    deinit {
        print("x deinit: \(type(of: self))")
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
