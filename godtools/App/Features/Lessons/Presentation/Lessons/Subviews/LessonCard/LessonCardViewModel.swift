//
//  LessonCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

class LessonCardViewModel: ObservableObject {
        
    private let lessonListItem: LessonListItemDomainModelInterface
    private let attachmentsRepository: AttachmentsRepository
    
    private var getBannerImageCancellable: AnyCancellable?
        
    @Published var title: String = ""
    @Published var titleLayoutDirection: LayoutDirection = .rightToLeft
    @Published var appLanguageAvailability: String = ""
    @Published var bannerImageData: OptionalImageData?
    @Published var shouldShowLessonProgress: Bool = false
    @Published var lessonProgress: Double = 0
    @Published var completionString: String = ""
    @Published var attachmentsDownloadProgressValue: Double = 0
    @Published var translationDownloadProgressValue: Double = 0
    
    init(lessonListItem: LessonListItemDomainModelInterface, attachmentsRepository: AttachmentsRepository) {
        
        self.lessonListItem = lessonListItem
        self.attachmentsRepository = attachmentsRepository
        self.title = lessonListItem.name
        self.titleLayoutDirection = lessonListItem.nameLanguageDirection == .leftToRight ? .leftToRight : .rightToLeft
        self.appLanguageAvailability = lessonListItem.availabilityInAppLanguage.availabilityString
        
        let lessonProgress = lessonListItem.lessonProgress
        switch lessonProgress {
        case .hidden:
            shouldShowLessonProgress = false
            completionString = ""
            
        case .inProgress(let progress, let progressString):
            shouldShowLessonProgress = true
            self.lessonProgress = progress
            completionString = progressString
            
        case .complete(let completeString):
            shouldShowLessonProgress = false
            completionString = completeString
        }
        
        downloadBannerImage()
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = lessonListItem.bannerImageId
        
        if let cachedImage = attachmentsRepository.getAttachmentImageFromCache(id: attachmentId) {
            
            bannerImageData = OptionalImageData(image: cachedImage, imageIdForAnimationChange: attachmentId)
        }
        else {
            
            getBannerImageCancellable = attachmentsRepository.getAttachmentImagePublisher(id: attachmentId, requestPriority: .high)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (image: Image?) in
                    self?.bannerImageData = OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
                }
        }
    }
}
