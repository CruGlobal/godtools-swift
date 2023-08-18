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
    
    @Published var bannerImage: Image?
    
    let isSelected: Bool
    let name: String
    let description: String
    let languages: String
    let primaryLanguageName: String?
    let primaryLanguageIsSupported: Bool
    let parallelLanguageName: String?
    let parallelLanguageIsSupported: Bool
    
    init(toolVersion: ToolVersionDomainModel, attachmentsRepository: AttachmentsRepository, isSelected: Bool) {
        
        self.toolVersion = toolVersion
        self.attachmentsRepository = attachmentsRepository
        self.isSelected = isSelected
        
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.numberOfLanguagesString
        primaryLanguageName = toolVersion.primaryLanguage
        primaryLanguageIsSupported = toolVersion.primaryLanguageIsSupported
        parallelLanguageName = toolVersion.parallelLanguage
        parallelLanguageIsSupported = toolVersion.parallelLanguageIsSupported
        
        downloadBannerImage()
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = toolVersion.bannerImageId
        
        if let cachedImage = attachmentsRepository.getAttachmentImageFromCache(id: attachmentId) {
            
            bannerImage = cachedImage
        }
        else {
            
            getBannerImageCancellable = attachmentsRepository.getAttachmentImagePublisher(id: attachmentId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (image: Image?) in
                    self?.bannerImage = image
                }
        }
    }
}
