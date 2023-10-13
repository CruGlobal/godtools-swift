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
    @Published var appLanguageAvailability: String = ""
    @Published var bannerImageData: OptionalImageData?
    @Published var attachmentsDownloadProgressValue: Double = 0
    @Published var translationDownloadProgressValue: Double = 0
    
    init(lessonListItem: LessonListItemDomainModelInterface, attachmentsRepository: AttachmentsRepository) {
        
        self.lessonListItem = lessonListItem
        self.attachmentsRepository = attachmentsRepository
        self.title = lessonListItem.name
        self.appLanguageAvailability = lessonListItem.availabilityInAppLanguage
        
        downloadBannerImage()
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = lessonListItem.bannerImageId
        
        if let cachedImage = attachmentsRepository.getAttachmentImageFromCache(id: attachmentId) {
            
            bannerImageData = OptionalImageData(image: cachedImage, imageIdForAnimationChange: attachmentId)
        }
        else {
            
            getBannerImageCancellable = attachmentsRepository.getAttachmentImagePublisher(id: attachmentId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (image: Image?) in
                    self?.bannerImageData = OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
                }
        }
    }
}
