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

@MainActor class ReviewShareShareableViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let toolId: String
    private let shareable: ShareableDomainModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getReviewShareShareableStringsUseCase: GetReviewShareShareableStringsUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    private let trackShareShareableTapUseCase: TrackShareShareableTapUseCase
   
    private var imageToShare: UIImage?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings = ReviewShareShareableStringsDomainModel.emptyValue
    
    @Published var imagePreviewData: OptionalImageData?
    
    init(flowDelegate: FlowDelegate, toolId: String, shareable: ShareableDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getReviewShareShareableStringsUseCase: GetReviewShareShareableStringsUseCase, getShareableImageUseCase: GetShareableImageUseCase, trackShareShareableTapUseCase: TrackShareShareableTapUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.shareable = shareable
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getReviewShareShareableStringsUseCase = getReviewShareShareableStringsUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        self.trackShareShareableTapUseCase = trackShareShareableTapUseCase
        
        getCurrentAppLanguageUseCase
        .execute()
        .receive(on: DispatchQueue.main)
        .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getReviewShareShareableStringsUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (strings: ReviewShareShareableStringsDomainModel) in
                
                self?.strings = strings
            })
            .store(in: &cancellables)
        
        getShareableImageUseCase
            .execute(shareable: shareable)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (domainModel: ShareableImageDomainModel?) in
              
                if let imageData = domainModel?.imageData, let uiImage = UIImage(data: imageData) {
                         
                    self?.imageToShare = uiImage
                    
                    self?.imagePreviewData = OptionalImageData(
                        image: Image(uiImage: uiImage),
                        imageIdForAnimationChange: domainModel?.dataModelId
                    )
                }
            })
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func trackShareImageTappedAnalytics() {
        
        trackShareShareableTapUseCase
            .execute(
                toolId: toolId,
                shareableId: shareable.dataModelId
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
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
