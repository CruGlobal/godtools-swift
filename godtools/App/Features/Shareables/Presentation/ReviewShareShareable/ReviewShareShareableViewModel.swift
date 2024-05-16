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
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let toolId: String
    private let shareable: ShareableDomainModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewReviewShareShareableUseCase: ViewReviewShareShareableUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    private let trackShareShareableTapUseCase: TrackShareShareableTapUseCase
   
    private var imageToShare: UIImage?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var imagePreviewData: OptionalImageData?
    @Published var shareImageButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, toolId: String, shareable: ShareableDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewReviewShareShareableUseCase: ViewReviewShareShareableUseCase, getShareableImageUseCase: GetShareableImageUseCase, trackShareShareableTapUseCase: TrackShareShareableTapUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.shareable = shareable
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewReviewShareShareableUseCase = viewReviewShareShareableUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        self.trackShareShareableTapUseCase = trackShareShareableTapUseCase
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewReviewShareShareableDomainModel, Never> in
                return viewReviewShareShareableUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
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
        
        trackShareShareableTapUseCase
            .trackPublisher(toolId: "", shareableId: shareable.dataModelId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &ReviewShareShareableViewModel.backgroundCancellables)
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
