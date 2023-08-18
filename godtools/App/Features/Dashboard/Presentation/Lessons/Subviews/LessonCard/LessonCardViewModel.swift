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
        
    private let lesson: LessonDomainModel
    private let attachmentsRepository: AttachmentsRepository
    
    private var getBannerImageCancellable: AnyCancellable?
        
    @Published var title: String = ""
    @Published var languageAvailability: String = ""
    @Published var bannerImageData: OptionalImageData?
    @Published var attachmentsDownloadProgressValue: Double = 0
    @Published var translationDownloadProgressValue: Double = 0
    
    init(lesson: LessonDomainModel, attachmentsRepository: AttachmentsRepository) {
        
        self.lesson = lesson
        self.attachmentsRepository = attachmentsRepository
        self.title = lesson.title
        self.languageAvailability = lesson.languageAvailability
        
        downloadBannerImage()
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = lesson.bannerImageId
        
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
