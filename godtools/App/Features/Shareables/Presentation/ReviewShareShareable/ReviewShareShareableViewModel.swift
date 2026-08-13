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

@MainActor
final class ReviewShareShareableViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let toolId: String
    private let shareable: ShareableDomainModel
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getReviewShareShareableStringsUseCase: GetReviewShareShareableStringsUseCase
    private let getShareableImageUseCase: GetShareableImageUseCase
    private let trackShareShareableTapUseCase: TrackShareShareableTapUseCase
   
    private var imageToShare: UIImage?
    private var cancellables: Set<AnyCancellable> = Set()
    private var getShareableImageTask: Task<Void, Error>?
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = ReviewShareShareableStringsDomainModel.emptyValue
    
    @Published var imagePreviewData: OptionalImageData?
    
    init(
        stepEmitter: FlowStepEmitter,
        toolId: String,
        shareable: ShareableDomainModel,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getReviewShareShareableStringsUseCase: GetReviewShareShareableStringsUseCase,
        getShareableImageUseCase: GetShareableImageUseCase,
        trackShareShareableTapUseCase: TrackShareShareableTapUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.toolId = toolId
        self.shareable = shareable
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getReviewShareShareableStringsUseCase = getReviewShareShareableStringsUseCase
        self.getShareableImageUseCase = getShareableImageUseCase
        self.trackShareShareableTapUseCase = trackShareShareableTapUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)
        
        loadShareableImage()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        getShareableImageTask?.cancel()
    }
    
    private func loadShareableImage() {
        
        getShareableImageTask?.cancel()
        
        getShareableImageTask = Task {
                
            do {
                
                let shareableImage = try await getShareableImageUseCase.execute(shareable: shareable)
                
                didRefreshShareableImage(shareableImage: shareableImage)
            }
            catch _ {
                
            }
        }
    }
    
    private func didRefreshShareableImage(shareableImage: ShareableImageDomainModel?) {
        
        guard let data = shareableImage?.imageData, let uiImage = UIImage(data: data) else {
            return
        }
        
        imagePreviewData = OptionalImageData(
            image: Image(uiImage: uiImage),
            imageIdForAnimationChange: shareableImage?.dataModelId
        )
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            strings = await getReviewShareShareableStringsUseCase
                .execute(
                    appLanguage: appLanguage
                )
        }
    }

    private func trackShareImageTappedAnalytics() {
        
        Task {
            await trackShareShareableTapUseCase
                .execute(
                    toolId: toolId,
                    shareableId: shareable.dataModelId
                )
        }
    }
}

// MARK: - Inputs

extension ReviewShareShareableViewModel {
    
    func closeTapped() {
        
        stepEmitter.emit(step: AppFlowStep.closeTappedFromReviewShareShareable)
    }
    
    func shareImageTapped() {
        
        guard let imageToShare = self.imageToShare else {
            return
        }
        
        stepEmitter.emit(step: AppFlowStep.shareImageTappedFromReviewShareShareable(shareImage: imageToShare))
        trackShareImageTappedAnalytics()
    }
}
