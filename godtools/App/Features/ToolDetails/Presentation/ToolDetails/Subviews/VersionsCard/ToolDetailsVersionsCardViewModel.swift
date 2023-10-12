//
//  ToolDetailsVersionsCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ToolDetailsVersionsCardViewModel: ObservableObject {
    
    private let toolVersion: ToolVersionDomainModel
    private let attachmentsRepository: AttachmentsRepository
    
    private var getBannerImageCancellable: AnyCancellable?
    
    @Published var bannerImageData: OptionalImageData?
    
    let isSelected: Bool
    let name: String
    let description: String
    let languages: String
    let toolLanguageName: String?
    let toolLanguageNameIsSupported: Bool
    
    init(toolVersion: ToolVersionDomainModel, attachmentsRepository: AttachmentsRepository, isSelected: Bool) {
        
        self.toolVersion = toolVersion
        self.attachmentsRepository = attachmentsRepository
        self.isSelected = isSelected
        
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.numberOfLanguages
        toolLanguageName = toolVersion.toolLanguageName
        toolLanguageNameIsSupported = toolVersion.toolLanguageNameIsSupported
        
        downloadBannerImage()
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = toolVersion.bannerImageId
        
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
