//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ToolCardViewModel: ObservableObject {
        
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let attachmentsRepository: AttachmentsRepository
            
    private var getBannerImageCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    let tool: ToolListItemDomainModelInterface
    
    @Published var bannerImageData: OptionalImageData?
    @Published var isFavorited = false
    @Published var name: String = ""
    @Published var category: String = ""
    @Published var languageAvailability: String = ""
    @Published var detailsButtonTitle: String = ""
    @Published var openButtonTitle: String = ""
            
    init(tool: ToolListItemDomainModelInterface, alternateLanguage: LanguageDomainModel? = nil, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.tool = tool
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
                        
        name = tool.name
        category = tool.category
        isFavorited = tool.isFavorited
        openButtonTitle = tool.interfaceStrings.openToolActionTitle
        detailsButtonTitle = tool.interfaceStrings.openToolDetailsActionTitle
        
        downloadBannerImage()
        setLanguageAvailabilityText(language: alternateLanguage)
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = tool.bannerImageId
        
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
    
    private func setLanguageAvailabilityText(language: LanguageDomainModel?) {
        
        // TODO: Implement back in. ~Levi
        
        /*
        let getLanguageAvailability = getLanguageAvailabilityUseCase.getLanguageAvailability(for: tool, language: language)
        
        if getLanguageAvailability.isAvailable {
            
            languageAvailability = getLanguageAvailability.availabilityString
            
        } else {
            languageAvailability = ""
        }*/
    }
}
